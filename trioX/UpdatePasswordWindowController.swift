//
//  UpdatePasswordWindowController.swift
// trioXLoginPlugin
//
//

import Cocoa

class UpdatePasswordWindowController: NSWindowController {

    @IBOutlet var currentPasswordTextField:NSTextField!

    @IBOutlet var passwordTextField:NSTextField!
    @IBOutlet var verifyPasswordTextField:NSTextField!
    @IBOutlet var passwordMatchWarningLabel:NSTextField!
    var password:String?
    var currentPassword:String?

    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.makeFirstResponder(currentPasswordTextField)
        passwordMatchWarningLabel.isHidden=true
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
        if passwordTextField.stringValue.count==0 ||  verifyPasswordTextField.stringValue.count == 0 ||
            currentPasswordTextField.stringValue.count == 0
        {
            return
        }

        if passwordTextField.stringValue != verifyPasswordTextField.stringValue {
            passwordMatchWarningLabel.isHidden=false
            return

        }
        if self.window?.isModalPanel==true {
            password=passwordTextField.stringValue
            currentPassword=currentPasswordTextField.stringValue
            NSApp.stopModal(withCode: .OK)
        }

    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if self.window?.isModalPanel==true {
            password=nil
            NSApp.stopModal(withCode: .cancel)
        }
    }
}
