//
//  AuthRIghtsHelper.swift
// trioX
//
//

import Foundation


class AuthRightsHelper: NSObject {
    static let rightsArray = [
        ["builtin:policy-banner":"TrioXLoginPlugin:UserSetup,privileged"],
        ["TrioXLoginPlugin:LoginWindow":"TrioXLoginPlugin:PowerControl,privileged"],
        ["loginwindow:done":"TrioXLoginPlugin:KeychainAdd,privileged"],
        ["builtin:login-begin":"TrioXLoginPlugin:CreateUser,privileged"],
        ["loginwindow:done":"TrioXLoginPlugin:EnableFDE,privileged"],
        ["loginwindow:done":"TrioXLoginPlugin:LoginDone"]
    ]

    static func resetRights() ->Bool {
        TCSLogWithMark("resetting rights")
        if AuthorizationDBManager.shared.rightExists(right:"TrioXLoginPlugin:LoginWindow")==true {
            TCSLogWithMark("replacing TrioXLoginPlugin:LoginWindow with loginwindow:login")
            if AuthorizationDBManager.shared.replace(right: "TrioXLoginPlugin:LoginWindow", withNewRight: "loginwindow:login") == false {
                TCSLogErrorWithMark("Error removing TrioXLoginPlugin:LoginWindow. bailing")
                return false
            }
        }
        else if AuthorizationDBManager.shared.rightExists(right: "loginwindow:login")==false {
            TCSLogErrorWithMark("There was no TrioXLoginPlugin:LoginWindow and no loginwindow:login. Please remove /var/db/auth.db and reboot")
            return false
        }

        for authRight in AuthorizationDBManager.shared.consoleRights() {
            if authRight.hasPrefix("TrioXLoginPlugin") {
                TCSLogWithMark("Removing \(authRight)")
                if AuthorizationDBManager.shared.remove(right: authRight) == false {
                    TCSLogErrorWithMark("Error removing \(authRight)")

                }
            }

        }
        return true

    }
    static func verifyRights() -> Bool {
        var foundRights=0

        for right in rightsArray {

            if AuthorizationDBManager.shared.rightExists(right: right.values.first!)==true {
                foundRights = foundRights + 1
            }

        }
        if foundRights == 0 && AuthorizationDBManager.shared.rightExists(right: "loginwindow:login")==true {
//            TCSLogWithMark("no TrioX rights but loginwindow:login exists, so we are good")
            return true
        }
        else if foundRights == rightsArray.count && AuthorizationDBManager.shared.rightExists(right: "loginwindow:login")==false{
//                TCSLogWithMark("all TrioX found and no loginwindow:login")

            return true
        }
        TCSLogWithMark("verified rights failed.")

        return false
    }
    static func addRights() ->Bool {

        TCSLogWithMark("Adding rights back in")
        if AuthorizationDBManager.shared.replace(right: "loginwindow:login", withNewRight: "TrioXLoginPlugin:LoginWindow")==false {
            TCSLogWithMark("error adding loginwindow:login after TrioXLoginPlugin:LoginWindow. bailing since this shouldn't happen")

            return false
        }

        for right in rightsArray {

            if AuthorizationDBManager.shared.rightExists(right: right.keys.first!){
                if AuthorizationDBManager.shared.rightExists(right:right.values.first!) == false {

                    if AuthorizationDBManager.shared.insertRight(newRight: right.values.first!, afterRight: right.keys.first!) {

                        TCSLogWithMark("adding \(right.values.first!) after \(right.keys.first!)")
                    }
                    else {
                        TCSLogWithMark("right \(right.values.first!) already exists. Skipping")

                    }
                }

                else {
                    TCSLogErrorWithMark("\(right.keys.first!) does not exist. not inserting \(right.values.first!)")
                }

            }
        }
        return true

    }

}
