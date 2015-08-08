//
//  DesktopPictureViewController.swift
//  WhichBG
//
//  Created by Utkarsh Upadhyay on 8/3/15.
//  Copyright (c) 2015 Utkarsh Upadhyay. All rights reserved.
//

import Cocoa
import Foundation
import SQLite

class DesktopPictureViewController: NSViewController {

    @IBAction func Exitaction(sender: NSButton) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    func refreshFiles() -> [String]? {
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
            
            return files
        } else {
            println("No Application Support directory was returned. Exiting.")
            return nil
        }
    }
    
    @IBOutlet weak var collectionView: NSScrollView!
    @IBOutlet weak var imageCollectionView: NSCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let imageWidth : CGFloat = 200.0, gutter : CGFloat = 10.0
        var numImages : Int = 0, lastImg : NSImageView? = nil
        
        if let files = self.refreshFiles() {
            // Silently ignoring the files for which data cannot be loaded
            let images = files.map { NSImage(contentsOfFile: $0) }.filter { $0 != nil }.map { $0! }
            self.imageCollectionView.itemPrototype = WallpaperItem()
            self.imageCollectionView.selectable = true
            self.imageCollectionView.content = images
            
            self.imageCollectionView!.autoresizingMask = .ViewMaxXMargin | .ViewMinXMargin | .ViewMaxYMargin | .ViewMinYMargin
            // self.imageCollectionView!.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable | NSAutoresizingMaskOptions.ViewMaxXMargin | NSAutoresizingMaskOptions.ViewMinYMargin | NSAutoresizingMaskOptions.ViewHeightSizable | NSAutoresizingMaskOptions.ViewMaxYMargin
            
            for (idx, img) in enumerate(images) {
                let item = self.imageCollectionView.itemAtIndex(idx) as? WallpaperItem
                item!.getView().image = img
            }
        } else {
            let errorLabel = NSTextView(frame: self.collectionView.frame)
            errorLabel.editable = false
            errorLabel.string = "Error!"
            
            self.collectionView.addSubview(errorLabel)
            // TODO: Show that nothing could be shown.
        }
    }
}

class WallpaperItem : NSCollectionViewItem {
    
    var wallpaperView: NSImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        // self.wallpaperView = NSImageView(frame: NSZeroRect)
        let marginX = CGFloat(0.0), marginY = CGFloat(0.0), imageWidth = CGFloat(320.0), imageHeight = CGFloat(240.0)
        self.wallpaperView = NSImageView(frame: NSMakeRect(marginX, marginY, imageWidth, imageHeight))
        self.view = self.wallpaperView!
    }
    
    func getView() -> NSImageView {
        return self.wallpaperView!
    }
}