//
//  WhitePopoverBackgroundView.swift
//  XCredsLoginPlugin
//
//

import Cocoa

class WhitePopoverBackgroundView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.white.set()
        bounds.fill()
        // Drawing code here.
    }
    
}
