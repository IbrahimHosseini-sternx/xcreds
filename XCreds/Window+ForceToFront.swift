//
//  Window+ForceToFront.swift
//  xCreds
//
//

import Foundation
import Cocoa

extension NSWindow {
    @objc func forceToFrontAndFocus(_ sender: AnyObject?) {
        NSApp.activate(ignoringOtherApps: true)
        self.makeKeyAndOrderFront(sender);
    }
}
