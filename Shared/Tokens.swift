//
//  Tokens.swift
// trioX
//
//

import Foundation
import OIDCLite
struct Creds {
    var password:String? = ""
    public var accessToken: String?
    public var idToken: String?
    public var refreshToken: String?
    public var jsonDict: [String:Any]?

    init(password:String?, tokens:OIDCLiteTokenResponse) {

        self.accessToken=tokens.accessToken
        self.idToken=tokens.idToken
        self.refreshToken=tokens.refreshToken
        self.password=password
        self.jsonDict=tokens.jsonDict

   }
    init(accessToken:String?, idToken:String?,refreshToken:String?, password:String?,jsonDict:Dictionary <String,Any>) {

        self.accessToken=accessToken
        self.idToken=idToken
        self.refreshToken=refreshToken
        self.password=password
        self.jsonDict=jsonDict

   }
    func hasTokens() -> Bool {

        return (self.accessToken != nil) && (self.idToken != nil) && (self.refreshToken != nil)
    }

    func hasAccessAndRefresh() -> Bool {

        return (self.accessToken != nil) && (self.refreshToken != nil)
    }
    func hasAccess() -> Bool {

        return (self.accessToken != nil)
    }

}



