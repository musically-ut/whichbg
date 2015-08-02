//
//  AppDelegate.swift
//  WhichBG
//
//  Created by Utkarsh Upadhyay on 6/20/15.
//  Copyright (c) 2015 Utkarsh Upadhyay. All rights reserved.
//

import Cocoa
import SQLite
import Foundation

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
        var screen = NSScreen.mainScreen() // <-- Is this the current screen?
        var workspace = NSWorkspace.sharedWorkspace() // <-- Is this the current workspace?
                                                      // What does shared mean anyway? Are there private
                                                      // workspaces as well?
        var bgImageOpts = workspace.desktopImageOptionsForScreen(screen!);
        var bgImageURL = workspace.desktopImageURLForScreen(screen!);
        println("ImageURL: \(bgImageURL) and opts: \(bgImageOpts)");
        
        // Magic brought to you by SO: 
        // http://stackoverflow.com/questions/30954492/how-to-get-the-path-to-the-current-workspace-screens-wallpaper-on-osx
        
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        if let appSupp = paths.first as? NSString {
            let dbPath = appSupp.stringByAppendingPathComponent("Dock/desktoppicture.db")
            let db = Database(dbPath)
            let value = Expression<String?>("value")
            
            // TODO: Correct error handling here.
            // Now by personal obseravtion, there are three kinds of entries in the `data` table.
            //   1. Folders (e.g. ~/Pictures)
            //   2. Numbers (e.g. 1)
            //   3. Absolute paths (e.g. /Library/Desktop Pictures/Yosemite.jpg)
            //   4. Relative filenames (e.g. 49 - Ei3XhvZ.jpg)
            //
            // Our strategy is to figure out the absolute paths and all possible combination of the folders and pictures
            // which exist and are valid image files. We'll show those items on a Grid and allow the user to open them
            // in finder using a single click.
            
            var filesFolders : [String] = []
            for row in db["data"] {
                if let fileFolder = row[value] {
                    filesFolders.append(fileFolder)
                }
            }
            let files = findAllExistingFilesIn(filesFolders)
            
            for f in files {
                println("File = \(f)")
            }
        } else {
            // TODO: Show an alert here and exit gracefully.
            println("No Application Support directory was returned. Exiting.")
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        println("Exiting.");
    }

}

