//
//  Helper+JWTDecode.swift
//  XCreds
//
//

import Foundation
func jwtDecode(value: String) -> Dictionary<String, Any>? {

    let array = value.components(separatedBy: ".")

    if array.count != 3 {
        TCSLogErrorWithMark("idToken is invalid")
        return nil
    }
    let body = array[1]
    guard let data = base64UrlDecode(value:body ) else {
        TCSLogErrorWithMark("error decoding id token base64")
        return nil
    }

    var idTokenObject:Dictionary<String, Any>?
    do {
        
         idTokenObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, Any>

        guard let idTokenObject = idTokenObject else {
            return nil
        }
        return idTokenObject

    }
    catch {
        return nil

    }

}
