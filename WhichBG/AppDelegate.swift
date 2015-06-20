//
//  AppDelegate.swift
//  WhichBG
//
//  Created by Utkarsh Upadhyay on 6/20/15.
//  Copyright (c) 2015 Utkarsh Upadhyay. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // The statusBarItem must continue to exist after the applicationDidFinishLaunch
    // function finishes execution. Otherwise, the item is promptly removed from the status bar.
    var statusBarItem : NSStatusItem?;

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Using -1 instead of NSVariableStatusItemLength
        // See: http://stackoverflow.com/a/24026327/987185
        statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        statusBarItem!.image = NSImage(named: "StatusIcon");
        statusBarItem!.toolTip = "Ctrl-Click to quit.";
        statusBarItem!.action = Selector("statusIconClicked:");
    }
    
    @IBAction func statusIconClicked(sender: NSStatusItem) {
        println("Clicked!");
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        println("Exiting.");
    }

}

