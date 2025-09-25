//
//  NSAlert+showAlert.swift
//  XCreds
//
//

import Cocoa

extension NSAlert {

    static func showAlert(title: String?, message: String?, style: NSAlert.Style = .informational) {
        let alert = NSAlert()
        if let title = title {
            alert.messageText = title
        }
        if let message = message {
            alert.informativeText = message
        }
        alert.alertStyle = style
        alert.runModal()
    }

}
