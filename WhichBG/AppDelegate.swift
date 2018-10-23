//
//  AppDelegate.swift
//  WhichBG
//
//  Created by Utkarsh Upadhyay on 6/20/15.
//  Copyright (c) 2015 Utkarsh Upadhyay. All rights reserved.
//

import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // The statusBarItem must continue to exist after the applicationDidFinishLaunch
    // function finishes execution. Otherwise, the item is promptly removed from the status bar.
    var statusBarItem : NSStatusItem?
    var outsideClickHandler: GlobalEventMonitor?
    let popOver = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Using -1 instead of NSVariableStatusItemLength
        // See: http://stackoverflow.com/a/24026327/987185
        statusBarItem = NSStatusBar.system().statusItem(withLength: -1);
        statusBarItem!.image = NSImage(named: "StatusIcon");
        
        // Make the Icons behave nicely on dark mode.
        statusBarItem!.image?.isTemplate = true;
        
        // statusBarItem!.action = Selector("statusIconClicked:");
        statusBarItem!.action = #selector(AppDelegate.togglePopover(_:))
        
        // This is the Popover we'll show:
        popOver.contentViewController = DesktopPictureViewController(nibName: "DesktopPictureViewController", bundle: nil)
        
        outsideClickHandler = GlobalEventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.popOver.isShown {
                self.closePopover(event)
            }
        }
        outsideClickHandler?.start()
    }
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusBarItem!.button {
            popOver.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popOver.performClose(sender)
    }
    
    @IBAction func togglePopover(_ sender: NSStatusItem) {
        if popOver.isShown {
            closePopover(sender)
            outsideClickHandler?.stop()
        } else {
            showPopover(popOver)
            outsideClickHandler?.start()
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("Exiting.");
    }

}

