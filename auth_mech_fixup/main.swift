//
//  main.swift
//  auth_mech_fixup
//
//

import Foundation

if AuthorizationDBManager.shared.rightExists(right: "TrioXLoginPlugin:LoginWindow") == true {
    TCSLogWithMark("TrioX auth rights already installed.")
    exit(0)

}
TCSLogErrorWithMark("TrioX rights do not exist. Fixing and rebooting")

if AuthRightsHelper.resetRights()==false {
    TCSLogErrorWithMark("error resetting rights")
    exit(1)
}
if AuthRightsHelper.addRights()==false {
    TCSLogErrorWithMark("error adding rights")
    exit(1)
}
