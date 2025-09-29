//
//  SecretKeeper.swift
//  encryptor
//
//

import Foundation
import CryptoKit

@objc(RFIDUsers)
public class RFIDUsers:NSObject, NSSecureCoding {

    public static var supportsSecureCoding: Bool {
        return true
    }
    public var userDict:Dictionary<Data,SecretKeeperUser>?
    public var salt:Data
    public func encode(with coder: NSCoder) {

        coder.encode(userDict, forKey:"userDict")
        coder.encode(salt, forKey:"salt")

    }

    public required init?(coder: NSCoder) {

        userDict = coder.decodeObject(forKey: "userDict") as? Dictionary<Data,SecretKeeperUser>
        self.salt = coder.decodeObject(forKey: "salt") as? Data ?? Data()
    }

    init(rfidUsers:[Data:SecretKeeperUser]) {
        self.userDict = rfidUsers
        var bytes = [Int8](repeating: 0, count: 10)
        let _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        self.salt = Data(bytes: bytes, count: 16)
    }


}

@available(macOS, deprecated: 11)
public struct PasswordCryptor{

    public enum PasswordCryptorError:Error {
        case saltLengthError
        case randomNumberGeneratingError
        case badInputDataLength
        case badSalt
    }

    //the uid is less than 16 byte for AES128, so the user
    //password is not encrypted with just the UID. The UID
    //is padded with 0 byte to get it up to 7 bytes. then
    //the mac serial number is appended to it and and SHA256
    //is taken to get exactly 16 bytes for the symmetric key

    func keyForAES(rfidUID:Data, salt:Data?, pin:String?) throws -> (key:SymmetricKey,salt:Data?) {
        var keyBuffer = Data()
        
        keyBuffer.append(rfidUID)

        if keyBuffer.count<7 {
            for _ in keyBuffer.count..<7 {
                keyBuffer.append(0x00)
            }
        }
        let serialNumber = getSerial().data(using: .utf8)

        if let pin = pin, let pinData = pin.data(using: .utf8) {
            keyBuffer.append(pinData)
        }

        guard let serialNumber = serialNumber else {
            TCSLogWithMark("serial number error")
            throw SecretKeeper.SecretKeeperError.aesEncryptionError

        }

        keyBuffer.append(serialNumber)

        let (hashedData, salt) = try hashSecretWithKeyStretchingAndSalt(secret: keyBuffer, salt: salt)

        let symmetricKey = SymmetricKey(data: hashedData)

        return (symmetricKey,salt)
    }
    func passwordDecrypt(encryptedDataWithSalt:Data, rfidUID:Data, pin:String?) throws -> Data{
        if encryptedDataWithSalt.count < 16 {

            throw PasswordCryptorError.badInputDataLength

        }
        let salt = encryptedDataWithSalt[0...15]
        let data = encryptedDataWithSalt[16...]

        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let (key, _) = try keyForAES(rfidUID:rfidUID, salt: salt, pin:pin)
        let clearTextData = try AES.GCM.open(sealedBox, using:key )

        return clearTextData

    }
    func passwordEncrypt(clearTextData:Data, rfidUID:Data, pin:String?) throws -> Data{

        let (key, salt) = try keyForAES(rfidUID:rfidUID, salt:nil, pin:pin)
        guard let salt = salt else {
            throw PasswordCryptorError.badSalt
        }
        let sealed = try AES.GCM.seal(clearTextData, using:key )

        guard let encryptedData = sealed.combined else {
            TCSLogWithMark("seal error")

            throw SecretKeeper.SecretKeeperError.aesEncryptionError
        }

        return salt+encryptedData
    }
    public func hashSecretWithKeyStretchingAndSalt(secret:Data, salt inSalt:Data?) throws -> (hashedValue:Data,salt:Data)  {

        var salt:Data
        if let inSalt = inSalt {
            salt = inSalt
        }
        else {
            var newSaltBytes = [Int8](repeating: 0, count: 16)

            let status = SecRandomCopyBytes(kSecRandomDefault, newSaltBytes.count, &newSaltBytes)

            if status != errSecSuccess { // Always test the status.
                throw PasswordCryptorError.randomNumberGeneratingError
            }
            let newSalt = Data(bytes: newSaltBytes, count: 16)
            salt = newSalt
        }


        var hashedUID=Data(SHA256.hash(data: secret+salt))
        for _ in 0...65535 {
            hashedUID=Data(SHA256.hash(data: hashedUID+secret+salt))
        }

        return (hashedUID,salt)
    }
}

@objc(SecretKeeperUser)
public class SecretKeeperUser:NSObject, NSSecureCoding {
    enum SecretKeeperUserError:Error {
        case errorCreatingSalt
    }
    public static var supportsSecureCoding: Bool {
        return true
    }
    public var fullName:String?
    public var username:String
    public var password:Data
    public var userUID:NSNumber
    public var requiresPIN:Bool

    public func encode(with coder: NSCoder) {

        coder.encode(fullName, forKey:"fullName")
        coder.encode(username,forKey:"username")
        coder.encode(password,forKey:"password")
        coder.encode(userUID,forKey:"uid")
        coder.encode(requiresPIN, forKey:"requiresPIN")
    }

    public required init?(coder: NSCoder) {

        fullName = coder.decodeObject(forKey: "fullName") as? String
        username = coder.decodeObject(forKey: "username") as? String ?? ""
        password = coder.decodeObject(forKey: "password") as? Data ?? Data()
        userUID = coder.decodeObject(forKey: "uid") as? NSNumber ?? -1
        requiresPIN = coder.decodeBool(forKey: "requiresPIN")

    }
    @available(macOS, deprecated: 11)
    init(fullName: String, username: String, password: String, uid:NSNumber, rfidUID:Data, pin:String?)  throws {


        self.fullName = fullName
        self.username = username
        self.requiresPIN = pin != nil
        guard let passwordData = password.data(using: .utf8) else {
            throw SecretKeeper.SecretKeeperError.otherError("error converting password")
        }
        let encryptedPassword = try PasswordCryptor().passwordEncrypt(clearTextData: passwordData, rfidUID: rfidUID, pin: pin)
        self.password = encryptedPassword

        self.userUID = uid

    }



}
@objc(Secrets)
public class Secrets:NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool {
        return true
    }
    public var localAdmin:SecretKeeperUser
    public var rfidUIDUsers:RFIDUsers
    var salt:Data

    init(localAdmin:SecretKeeperUser, uidUsers:RFIDUsers){
        self.localAdmin = localAdmin
        self.rfidUIDUsers = uidUsers
        var salt = [Int8](repeating: 0, count: 16)
        let _ = SecRandomCopyBytes(kSecRandomDefault, salt.count, &salt)
        self.salt = Data(bytes: salt, count: 16)

    }

    public func encode(with coder: NSCoder) {
        coder.encode(localAdmin, forKey: "localAdmin")
        coder.encode(rfidUIDUsers, forKey: "rfidUIDUsers")
        coder.encode(salt, forKey: "salt")

    }
    @available(macOS, deprecated: 11)
    public required init?(coder: NSCoder) {

        do{
            localAdmin = try coder.decodeObject(forKey: "localAdmin") as? SecretKeeperUser ?? SecretKeeperUser(fullName: "", username: "", password: "", uid: -1, rfidUID: Data(),pin:nil)
            rfidUIDUsers = coder.decodeObject(of: RFIDUsers.self, forKey: "rfidUIDUsers") ?? RFIDUsers(rfidUsers: [:])

            salt = coder.decodeObject(forKey: "salt") as? Data ?? Data()
        }
        catch {
            TCSLogWithMark("error init of user object")
            return nil
        }
    }
}
public class SecretKeeper {
    public enum SecretKeeperError:Error {
        case errorFindingKey
        case privateKeyNotFound
        case errorCreatingKey(String)
        case errorRetrievingPublicKey
        case errorDecrypting
        case errorEncrypting
        case noSecretsFound
        case invalidSecretsData
        case invalidTag
        case errorWritingToSecretsFile
        case errorReadingSecretsFile
        case unknownError
        case aesEncryptionError
        case aesDecryptionError

        case otherError(String)

        func localizedDescription() -> String {
            switch self {

            case .errorFindingKey:
                return "errorFindingKey"
            case .privateKeyNotFound:
                return "privateKeyNotFound"

            case .errorCreatingKey(let error):
                return "errorCreatingKey: \(error)"

            case .errorRetrievingPublicKey:
                return "errorRetrievingPublicKey"

            case .errorDecrypting:
                return "errorDecrypting"

            case .errorEncrypting:
                return "errorEncrypting"

            case .noSecretsFound:
                return "noSecretsFound"

            case .invalidSecretsData:
                return "invalidSecretsData"

            case .invalidTag:
                return "invalidTag"

            case .errorWritingToSecretsFile:
                return "errorWritingToSecretsFile"

            case .errorReadingSecretsFile:
                return "errorReadingSecretsFile"

            case .unknownError:
                return "unknownError"

            case .otherError(let error):
                return error

            case .aesEncryptionError:
                return "aesEncryptionError"

            case .aesDecryptionError:
                return "aesDecryptionError"

            }


        }
    }

    private var label = ""
    private var tag = Data()
    private var secretsFolderURL:URL
    private var secretsFileURL:URL
    public init(label: String = "SecretKeeper", tag: String = "SecretKeeper", secretsFolderURL: URL = URL(fileURLWithPath: "/usr/local/var/triosoftinc")) throws {
        self.label = label
        self.secretsFolderURL = secretsFolderURL
        self.secretsFileURL = secretsFolderURL.appending(path: "secrets.bin")

        if let tagData = tag.data(using: .utf8) {
            self.tag = tagData
        }
        else {
            throw SecretKeeperError.invalidTag
        }
    }

    @available(macOS, deprecated: 11)
    func findExistingPrivateKey() throws -> SecKey? {

        let keychain = try systemKeychain()

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecUseKeychain as String:keychain as Any,

            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrApplicationTag as String: tag,
            kSecPrivateKeyAttrs as String:
               [kSecAttrLabel : label as CFString,
                kSecAttrIsPermanent as String:    true,
                kSecAttrApplicationTag as String: tag],

            kSecReturnRef as String: true
        ]

        var item: CFTypeRef?

        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)

    }
    @available(macOS, deprecated: 11)
    func systemKeychain()  throws -> SecKeychain{
        var keychain:SecKeychain?
        if SecKeychainCopyDomainDefault(SecPreferencesDomain.system, &keychain) != errSecSuccess {
            throw SecretKeeperError.errorFindingKey
        }

        if let keychain = keychain {
            return keychain
        }
        throw SecretKeeperError.unknownError


    }
    @available(macOS, deprecated: 11)
    func privateKey() throws -> SecKey {

        if let privateKey = try findExistingPrivateKey() {
            return privateKey
        }

       let keychain = try systemKeychain()


        var secApps = [ SecTrustedApplication ]()

        var trust : SecTrustedApplication? = nil
        if FileManager.default.fileExists(atPath: "/Applications/trioX.app", isDirectory: nil) {
            @available(macOS, deprecated: 10.10)
            let err = SecTrustedApplicationCreateFromPath("/Applications/trioX.app", &trust)

            if err == 0 {
                secApps.append(trust!)
            }
        }
        if FileManager.default.fileExists(atPath: "/System/Library/Frameworks/Security.framework/Versions/A/MachServices/authorizationhost.bundle/Contents/XPCServices/authorizationhosthelper.x86_64.xpc", isDirectory: nil) {

            @available(macOS, deprecated: 10.10)
            let err = SecTrustedApplicationCreateFromPath("/System/Library/Frameworks/Security.framework/Versions/A/MachServices/authorizationhost.bundle/Contents/XPCServices/authorizationhosthelper.x86_64.xpc", &trust)
            if err == 0 {
                secApps.append(trust!)
            }
        }
        if FileManager.default.fileExists(atPath: "/System/Library/Frameworks/Security.framework/Versions/A/MachServices/authorizationhost.bundle/Contents/XPCServices/authorizationhosthelper.arm64.xpc", isDirectory: nil) {
            let err = SecTrustedApplicationCreateFromPath("/System/Library/Frameworks/Security.framework/Versions/A/MachServices/authorizationhost.bundle/Contents/XPCServices/authorizationhosthelper.arm64.xpc", &trust)
            if err == 0 {
                secApps.append(trust!)
            }
        }

        var secAccess:SecAccess?
        let _ = SecAccessCreate("TrioX Encryptor" as CFString, secApps as CFArray, &secAccess)
        let attributes: [String: Any] =
        [kSecAttrKeyType as String:
            kSecAttrKeyTypeECSECPrimeRandom,
         kSecUseKeychain as String:keychain as Any,
         kSecAttrKeySizeInBits as String:      256,
         kSecAttrIsExtractable as String:false,
         kSecAttrAccess as String: secAccess ?? "",
         kSecPrivateKeyAttrs as String:
            [kSecAttrLabel : label as CFString,
             kSecAttrIsPermanent as String:    true,
             kSecAttrApplicationTag as String: tag],
        ]
        var error: Unmanaged<CFError>?
        guard let _ = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            var errorString = ""
            if let err = error?.takeUnretainedValue().localizedDescription{
                errorString = err
            }
            throw SecretKeeperError.errorCreatingKey(errorString)

        }
        guard let privateKey = try findExistingPrivateKey() else {
            throw SecretKeeperError.privateKeyNotFound
        }
        return privateKey
    }
    @available(macOS, deprecated: 11)
    func publicKey() throws -> SecKey{

        let privateKey = try privateKey()
        let publicKey = SecKeyCopyPublicKey(privateKey)

        if let publicKey = publicKey {
            return publicKey
        }
        throw SecretKeeperError.errorRetrievingPublicKey
    }
    @available(macOS, deprecated: 11)
    func decryptData(_ data:Data) throws -> Data {
        var error: Unmanaged<CFError>?

        let privateKey = try privateKey()
        let decryptedData = SecKeyCreateDecryptedData(privateKey, SecKeyAlgorithm.eciesEncryptionStandardX963SHA1AESGCM, data as CFData, &error)

        if let decryptedData = decryptedData {

            return decryptedData as Data
        }
        throw SecretKeeperError.errorDecrypting


    }
    @available(macOS, deprecated: 11)
    func encryptData(_ data:Data) throws -> Data {

        let publicKey = try publicKey()
        var error: Unmanaged<CFError>?

        let encryptedData = SecKeyCreateEncryptedData(publicKey,SecKeyAlgorithm.eciesEncryptionStandardX963SHA1AESGCM,data as CFData, &error)


        if let encryptedData = encryptedData {
            return encryptedData as Data
        }
        throw SecretKeeperError.errorEncrypting


    }



}
@available(macOS, deprecated: 11)
extension SecretKeeper {
    func saveSecrets(_ secrets:Secrets) throws {


        let data = try NSKeyedArchiver.archivedData(withRootObject:secrets,requiringSecureCoding: true)

        let encrypted = try encryptData(data)
        var attributes = [FileAttributeKey : Any]()
        attributes[.posixPermissions] = 0o600
        attributes[.ownerAccountID] = 0
        attributes[.groupOwnerAccountID] = 0

        try FileManager.default.createDirectory(at: secretsFolderURL, withIntermediateDirectories: true, attributes:attributes)
        try encrypted.write(to:secretsFileURL )
        try FileManager.default.setAttributes(attributes, ofItemAtPath: secretsFolderURL.path() )

    }
    func secrets() throws -> Secrets {

        if FileManager.default.fileExists(atPath: secretsFileURL.path()) == false {
            return try Secrets(localAdmin: SecretKeeperUser(fullName: "", username: "", password: "", uid: 0, rfidUID: Data(), pin: nil), uidUsers:RFIDUsers(rfidUsers: [:]))
        }
        
        let secretData = try Data(contentsOf: secretsFileURL)

        let decryptedData = try decryptData(secretData)


        guard let secrets = NSKeyedUnarchiver.unarchiveObject(with: decryptedData) as? Secrets else {
            TCSLog("Error unarchiving")
            throw SecretKeeperError.otherError("Error unarchiving")
        }
        return secrets
        }


}
