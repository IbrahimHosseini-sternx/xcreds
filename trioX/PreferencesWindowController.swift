//
//  PreferencesWindowController.swift
// trioX
//
//

import Foundation
import Cocoa

class PreferencesWindowController: NSWindowController {

    @IBOutlet weak var clearTokenButton: NSButton!

    @objc override var windowNibName: NSNib.Name {
        return NSNib.Name("PreferencesWindow")
    }
    @available(macOS, deprecated: 11)
    @IBAction func clearTokensClicked(_ sender: Any) {
        let keychainUtil = KeychainUtil()
        let _ = keychainUtil.findAndDelete(serviceName:"trioX",accountName:PrefKeys.accessToken.rawValue)
        let _ = keychainUtil.findAndDelete(serviceName:"trioX",accountName:PrefKeys.idToken.rawValue)
        let _ = keychainUtil.findAndDelete(serviceName:"trioX",accountName:PrefKeys.refreshToken.rawValue)


//        sharedMainMenu.signedIn=false
//        sharedMainMenu.buildMenu()
    }

}
