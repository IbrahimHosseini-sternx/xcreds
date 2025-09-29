//
//  TCSTrioXLoginOverlayWindow.swift
// trioX Login Overlay
//
//

import Cocoa

class TCSTrioXLoginOverlayWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect:contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        alphaValue=1.0
        backgroundColor=NSColor.clear
    }
}
