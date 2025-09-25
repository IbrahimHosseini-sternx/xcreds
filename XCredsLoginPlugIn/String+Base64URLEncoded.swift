//
//  File.swift
//  
//
//

import Foundation

extension String {
    func base64URLEncoded() -> String {
        var temp = self
        temp = temp.replacingOccurrences(of: "+", with: "-")
        temp = temp.replacingOccurrences(of: "/", with: "_")
        temp = temp.replacingOccurrences(of: "=", with: "")
        return temp
    }
}
