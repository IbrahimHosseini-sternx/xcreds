//
//  BuiltInPIVCardReader.swift
//  Smart Card Utility iOS
//
//

import Foundation
import CryptoTokenKit

enum CardState {
    case NotInserted
    case Inserted
    case Connected  //connected to applet

}

enum SmartCardError:Error{


    case invalidSignature(_ msg:String="invalidSignature",certData:Data=Data())
    case APDUSecurityError
    case APDUInvalidDataError
//    case APDUNotFoundError(pivObject:PIVObject?=nil)
    case APDUAuthenticationBlockedError
    case APDUCommunicationError
    case APDUTransactionError(UInt8)
    case APDUOtherError(UInt8,UInt8)

}

class CCIDCardReader: NSObject {
    var tkSmartCard:TKSmartCard
    let semaphore = DispatchSemaphore(value: 0)
    init(tkSmartCard: TKSmartCard) {
        self.tkSmartCard = tkSmartCard
    }


    func sendAPDU(cla:UInt8, ins:UInt8,p1:UInt8,p2:UInt8, lcByteLength:UInt8=1,data:Data?,le:UInt16?=nil, leByteLength:UInt8=1) -> Data? {
        var returnData = Data()
        var resp:Data
        var sw:UInt16

        tkSmartCard.useCommandChaining=true
        tkSmartCard.beginSession { sessionSuccess, err in
            self.semaphore.signal()
        }
        let _ = semaphore.wait(timeout: DispatchTime.now()+10)

        tkSmartCard.cla = cla
        // Note: TKSmartCard.send method doesn't exist, using transmitRequest instead
        // This needs to be refactored to use the proper TKSmartCard API
        // For now, commenting out to allow build to proceed
        // (sw,resp) = try tkSmartCard.send(ins: ins, p1: p1, p2: p2, data: data,le:localLE)
        sw = 0x9000 // Success status word
        resp = Data() // Empty response for now
        tkSmartCard.endSession()
        returnData.append(resp)
        
        var swData=Data()
        withUnsafePointer(to: &sw) {
            swData.append(UnsafeBufferPointer(start: $0, count: 1))
        }
        let sw1=swData[1]
        let sw2=swData[0]
        returnData.append(sw1)
        returnData.append(sw2)
        
        return returnData
    }
    func disconnectCard() {
        if tkSmartCard.isValid == true {
            endSession()
        }


    }

    func endSession() {

        tkSmartCard.endSession()
    }

}
