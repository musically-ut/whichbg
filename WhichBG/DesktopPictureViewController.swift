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
    
    @IBAction func helpAction(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/musically-ut/WhichBG")!)
    }
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    func refreshFiles() -> [String]? {
        // Magic brought to you by SO:
        // http://stackoverflow.com/questions/30954492/how-to-get-the-path-to-the-current-workspace-screens-wallpaper-on-osx
        
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        if let appSupp = paths.first as String? {
            let dbPath = NSURL(fileURLWithPath: appSupp).URLByAppendingPathComponent("Dock/desktoppicture.db")
            if isFile(dbPath.path!) {
                if let db = try? Connection(dbPath.path!) {
                    
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
                    if let data = try? db.prepare(Table("data")) {
                        var filesFolders : [String] = []
                        for row in data {
                            if let fileFolder = row[value] {
                                filesFolders.append(fileFolder)
                            }
                        }
                        return findAllExistingFilesIn(filesFolders)
                    } else {
                        print("No table 'data' found in the DB.")
                        return nil
                    }
                } else {
                    print("Unable to connect to DB.")
                    return nil
                }
            } else {
                print("The database file was not found.")
                return nil
            }
        } else {
            print("No Application Support directory was returned. Exiting.")
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
            let imagesAndPaths = files.map { ($0, NSImage(contentsOfFile: $0)) }.filter { $0.1 != nil }.map { ($0.0, $0.1!) }
            
            let contentHeight = self.collectionView.contentSize.height
            let gutter = CGFloat(10)
            
            self.imageCollectionView.minItemSize = NSMakeSize((16.0 / 10.0) * contentHeight + gutter, contentHeight)
            self.imageCollectionView.itemPrototype = WallpaperItem()
            self.imageCollectionView.selectable = true
            self.imageCollectionView.content = imagesAndPaths.map { $0.1 }

            for (idx, imgPathTuple) in imagesAndPaths.enumerate() {
                let item = self.imageCollectionView.itemAtIndex(idx) as? WallpaperItem
                item!.setImage(imgPathTuple.1, path: imgPathTuple.0)
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
    var path : String?
    
    override func loadView() {
        self.wallpaperView = NSImageView(frame: NSZeroRect)
        self.view = self.wallpaperView!
    }
    
    func setImage(image: NSImage, path: String) {
        self.path = path
        self.wallpaperView!.image = image
    }
    
    override var selected : Bool {
        didSet {
            if (selected && self.path != nil) {
                print("Showing path: \(self.path)")
                let fileURL = NSURL(fileURLWithPath: self.path!)
                NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([ fileURL ])
            }
        }
    }
}