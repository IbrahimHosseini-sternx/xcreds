//
//  DesktopLoginWindow.swift
// trioX
//
//

import Cocoa
@available(macOS, deprecated: 11)
class DesktopLoginWindowController: NSWindowController {
    @IBOutlet var webViewController: WebViewController!
    @IBOutlet var backgroundImageView:NSImageView!

    override class func awakeFromNib() {
        
    }
    override func windowDidLoad() {
        super.windowDidLoad()


        let backgroundImage = DefaultsHelper.desktopPasswordWindowBackgroundImage(includeDefault: false)

        if let backgroundImage = backgroundImage   {
            backgroundImageView.image = backgroundImage
            backgroundImageView.alphaValue = CGFloat(DefaultsOverride.standardOverride.float(forKey: PrefKeys.menuItemWindowBackgroundImageAlpha.rawValue))
            backgroundImageView.image=backgroundImage
            backgroundImageView.imageScaling = .scaleNone
        }

        

    }

}
