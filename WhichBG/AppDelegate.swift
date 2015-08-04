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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Using -1 instead of NSVariableStatusItemLength
        // See: http://stackoverflow.com/a/24026327/987185
        statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        statusBarItem!.image = NSImage(named: "StatusIcon");
        // statusBarItem!.action = Selector("statusIconClicked:");
        statusBarItem!.action = Selector("togglePopover:")
        
        // This is the Popover we'll show:
        popOver.contentViewController = DesktopPictureViewController(nibName: "DesktopPictureViewController", bundle: nil)
        
        outsideClickHandler = GlobalEventMonitor(mask: .LeftMouseDownMask | .RightMouseDownMask) { [unowned self] event in
            if self.popOver.shown {
                self.closePopover(event)
            }
        }
        outsideClickHandler?.start()
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusBarItem!.button {
            popOver.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSMinYEdge)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popOver.performClose(sender)
    }
    
    @IBAction func togglePopover(sender: NSStatusItem) {
        if popOver.shown {
            closePopover(sender)
            outsideClickHandler?.stop()
        } else {
            showPopover(popOver)
            outsideClickHandler?.start()
        }
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        println("Exiting.");
    }

}

