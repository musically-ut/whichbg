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
            if isFile(dbPath) {
                let db = Database(dbPath)
                let value = Expression<String?>("value")

                // TODO: This function does no error handling.
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
                return findAllExistingFilesIn(filesFolders)
            } else {
                println("The database file was not found.")
                return nil
            }
        } else {
            println("No Application Support directory was returned. Exiting.")
            return nil
        }
    }
    
    @IBOutlet weak var collectionView: NSScrollView!
    @IBOutlet weak var imageCollectionView: NSCollectionView!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if let files = self.refreshFiles() {
            self.imageCollectionView.hidden = false
            
            // Silently ignoring the files for which data cannot be loaded
            let images = files.map { NSImage(contentsOfFile: $0) }.filter { $0 != nil }.map { $0! }
            
            let contentHeight = self.collectionView.contentSize.height
            let gutter = CGFloat(10)
            
            self.imageCollectionView.minItemSize = NSMakeSize((16.0 / 10.0) * contentHeight + gutter, contentHeight)
            self.imageCollectionView.itemPrototype = WallpaperItem()
            self.imageCollectionView.selectable = true
            self.imageCollectionView.content = images

            for (idx, img) in enumerate(images) {
                let item = self.imageCollectionView.itemAtIndex(idx) as? WallpaperItem
                item!.getView().image = img
            }
        } else {
            self.imageCollectionView.hidden = true
            let errorLabel = NSTextView(frame: self.collectionView.frame)
            errorLabel.drawsBackground = false
            errorLabel.alignCenter(nil)
            errorLabel.string = "Sorry, could not load the wallpapers."
            
            let fontSize = CGFloat(16), contentSize = self.collectionView.contentSize
            errorLabel.frame = NSMakeRect(0, (contentSize.height - fontSize) / 2, contentSize.width, fontSize)
            errorLabel.editable = false
  
            self.collectionView.addSubview(errorLabel)
        }
    }
}

class WallpaperItem : NSCollectionViewItem {
    var wallpaperView: NSImageView?
    
    override func loadView() {
        self.wallpaperView = NSImageView(frame: NSZeroRect)
        self.view = self.wallpaperView!
    }
    
    func getView() -> NSImageView {
        return self.wallpaperView!
    }
}