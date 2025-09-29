//
//  AppDelegate.swift
// trioX Login Overlay
//
//

import Cocoa
import AppKit

@main
class App {
    static func main() {
        if let ud = UserDefaults(suiteName: "so.trio.trioX") {
            var delay = ud.integer(forKey: "overlayDelaySecs")
            if delay<10 {
                delay = 10
            }
            TCSLogWithMark("delaying overlay by \(delay) secs");
            sleep(UInt32(delay))
        }
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var cloudLoginTextField: NSTextField!
    @IBOutlet var window: NSWindow!
    @IBOutlet var waitWindow: NSWindow!
    var returnFileExistedOnStart = false

    var timer:Timer?
    @IBAction func cloudLoginButtonPressed(_ sender: Any) {

        var shouldSwitch = true

        if UserDefaults.standard.bool(forKey:PrefKeys.shouldUseKillWhenLoginWindowSwitching.rawValue)==false{

            let alert = NSAlert()
            alert.addButton(withTitle: "Restart")
            alert.addButton(withTitle: "Cancel")
            alert.messageText="Switching login windows requires a restart. Do you want to restart now?"

            alert.window.canBecomeVisibleWithoutLogin=true


            alert.icon=Bundle.main.image(forResource: NSImage.Name("icon_128x128"))


            if alert.runModal() == .alertSecondButtonReturn {
                shouldSwitch=false
            }
        }
        if shouldSwitch == false {
            return

        }
        waitWindow.level = .modalPanel
        waitWindow.canBecomeVisibleWithoutLogin = true
        let screenRect = NSScreen.screens[0].visibleFrame

        let screenWidth = screenRect.width
        let screenHeight = screenRect.height
        let waitWindowWidth = waitWindow.frame.width

        let newPos = NSMakePoint(screenWidth/2-waitWindowWidth/2, screenHeight/2)
        waitWindow.setFrameOrigin(newPos)
        waitWindow.makeKeyAndOrderFront(self)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            TCSLogWithMark("creating return file so TrioX does not return to mac login if it is set to go to mac login window by default.")
            do {
                try StateFileHelper().createFile(.returnType)
            }
            catch {
                TCSLogWithMark("not create trioX_return file:\(error)")
            }
            if UserDefaults.standard.bool(forKey: "slowReboot")==true {
               sleep(30)
            }
            let _ = AuthRightsHelper.addRights()

            StateFileHelper().killOrReboot()



        }
    }

/*
 (void)showStatusBar:(__unused id)sender{

     [self updateStatus:self];
     [self.returnToBootRunnerWindow setLevel:NSScreenSaverWindowLevel];


     [self.returnToBootRunnerWindow setCanBecomeVisibleWithoutLogin:YES];
     [self.returnToBootRunnerWindow setHidesOnDeactivate:NO];
     [self.returnToBootRunnerWindow setOpaque:NO];
     [self.returnToBootRunnerWindow orderFront:self];

     NSRect statusWindowRect=self.returnToBootRunnerWindow.frame;
     NSRect screenRect=[[[NSScreen screens] objectAtIndex:0] visibleFrame];

     statusWindowRect.size.width=screenRect.size.width;
     statusWindowRect.origin=screenRect.origin;
     [self.returnToBootRunnerWindow setFrame:statusWindowRect display:YES];

 }


 */
    func setupWindow()  {
        var statusWindowRect=window.frame
        let screenRect = NSScreen.screens[0].visibleFrame
        statusWindowRect.size.width=screenRect.size.width
        statusWindowRect.origin=screenRect.origin;
        window.setFrame(statusWindowRect, display: true, animate: false)
        window.canBecomeVisibleWithoutLogin=true
        window.hidesOnDeactivate=false
        window.isOpaque=false
        window.level = .modalPanel
        if let ud = UserDefaults(suiteName: "so.trio.trioX"),  let customTextString = ud.value(forKey: "cloudLoginText") {
            cloudLoginTextField.stringValue = customTextString as! String
            cloudLoginTextField.sizeToFit()

        }
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        TCSLogWithMark("starting overlay")
        UserDefaults.standard.addSuite(named: "so.trio.trioX")

        do {

            if StateFileHelper().fileExists(.returnType) == true {
                returnFileExistedOnStart = true
                try StateFileHelper().removeFile(.returnType)
            }

        }

        catch {

            TCSLogWithMark("Error removing return file: \(error)")
        }
        self.checkStatus()
        DispatchQueue.main.async {

            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in

                self.checkStatus()

            }
        }

    }
    func checkStatus()  {
        if  AuthRightsHelper.verifyRights() == false {
            TCSLogWithMark("rights are not correct. Fixing setting to xcloud. if mac login window is forced, will bounce back there after the cloud window shows.")
            let _ = AuthRightsHelper.resetRights()

            StateFileHelper().killOrReboot()
            return
        }

        if let ud = UserDefaults(suiteName: "so.trio.trioX"){

            if ud.bool(forKey: "shouldShowCloudLoginByDefault") == true,
               returnFileExistedOnStart == false,
               AuthorizationDBManager.shared.rightExists(right: "loginwindow:login")==true
            {
                TCSLogWithMark("we should be at TrioX window but we are at mac login window. Resetting and rebooting")

                let _ = AuthRightsHelper.addRights()
                TCSLogWithMark("TrioX rights added. Rebooting")
                if UserDefaults.standard.bool(forKey: "slowReboot")==true {
                   sleep(30)
                }
                StateFileHelper().killOrReboot()
                return
            }

        }
//        else {
//            TCSLogWithMark("rights correct")
//        }

        if AuthorizationDBManager.shared.rightExists(right: "loginwindow:login") == true {

            TCSLogWithMark("moving to front")
            NSApp.activate(ignoringOtherApps: true)
            self.setupWindow()
            NSApp.activate(ignoringOtherApps: true)
            self.window.orderFrontRegardless()
        }
//        else {
//            TCSLogWithMark("loginwindow:login does not exist so we are at TrioX login")
//        }


    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

