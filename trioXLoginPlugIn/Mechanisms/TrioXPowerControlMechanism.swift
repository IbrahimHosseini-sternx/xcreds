//
//  PowerControl.swift
//  NoMADLoginAD
//
//

import IOKit
import IOKit.pwr_mgt

enum SpecialUsers: String {
    case sleep
    case restart
    case shutdown
    case standardLoginWindow
}
@available(macOS, deprecated: 11)
class TrioXPowerControlMechanism: TrioXBaseMechanism {

    @objc override func run() {
        TCSLogWithMark("~~~~~~~~~~~~~~~~~~~ TrioXPowerControlMechanism mech starting starting mech starting ~~~~~~~~~~~~~~~~~~~")

//        if AuthorizationDBManager.shared.rightExists(right: "loginwindow:login"){
//            TCSLogWithMark("setting standard login back to TrioX login")
//            let _ = AuthorizationDBManager.shared.replace(right:"loginwindow:login", withNewRight: "TrioXLoginPlugin:LoginWindow")
//        }
        guard let userName = usernameContext else {
            TCSLogWithMark("No username was set somehow, pass the login to the next mech.")
            let _ = allowLogin()
            return

        }

        switch userName {
        case SpecialUsers.sleep.rawValue:
            TCSLogWithMark("Sleeping system.")
            let port = IOPMFindPowerManagement(mach_port_t(MACH_PORT_NULL))
            IOPMSleepSystem(port)
            IOServiceClose(port)
        case SpecialUsers.shutdown.rawValue:
            TCSLogWithMark("Shutting system down system")
            let _ = cliTask("/sbin/shutdown -h now")
        case SpecialUsers.restart.rawValue:
            TCSLogWithMark("Restarting system")
            let _ = cliTask("/sbin/shutdown -r now")

        case SpecialUsers.standardLoginWindow.rawValue:
            TCSLogWithMark("mechanism right to boot back to mac login window (SpecialUsers.standardLoginWindow)")
//            if
//                AuthorizationDBManager.shared.rightExists(right: "TrioXLoginPlugin:LoginWindow")==true{
//                if AuthorizationDBManager.shared.replace(right:"TrioXLoginPlugin:LoginWindow", withNewRight: "loginwindow:login") == false {
//                    TCSLogWithMark("could not replace loginwindow:login with TrioXLoginPlugin:LoginWindow")
//                }
//            }
//            for right in ["TrioXLoginPlugin:UserSetup,privileged","TrioXLoginPlugin:PowerControl,privileged","TrioXLoginPlugin:KeychainAdd,privileged","TrioXLoginPlugin:CreateUser,privileged","TrioXLoginPlugin:EnableFDE,privileged","TrioXLoginPlugin:LoginDone"] {
//
//                if AuthorizationDBManager.shared.rightExists(right:right)==true {
//                    if AuthorizationDBManager.shared.remove(right: right)
//                        == false {
//                        TCSLogWithMark("could not remove loginwindow right \(right)")
//                    }
//                }
//
//            }
            try? StateFileHelper().createFile(.returnType)
           let _ = AuthRightsHelper.resetRights()
            if UserDefaults.standard.bool(forKey: "slowReboot")==true {
               sleep(30)
            }
            StateFileHelper().killOrReboot()


        default:
            TCSLogWithMark("No special users named. pass login to the next mech.")

            let _ = allowLogin()
        }
    }
}
