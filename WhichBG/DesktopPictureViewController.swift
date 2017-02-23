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
    
    var errorString: String?;

    @IBAction func exitAction(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func helpAction(_ sender: AnyObject) {
        NSWorkspace.shared().open(URL(string: "https://github.com/musically-ut/WhichBG")!)
    }
    
    func refreshFiles() -> [String]? {
        // Magic brought to you by SO:
        // http://stackoverflow.com/questions/30954492/how-to-get-the-path-to-the-current-workspace-screens-wallpaper-on-osx
        
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        if let appSupp = paths.first as String? {
            let dbPath = URL(fileURLWithPath: appSupp).appendingPathComponent("Dock/desktoppicture.db")
            if isFile(dbPath.path) {
                if let db = try? Connection(dbPath.path) {
                    
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
                        errorString = "No table 'data' found in the DB."
                        return nil
                    }
                } else {
                    errorString = "Unable to connect to DB."
                    return nil
                }
            } else {
                errorString = "The database file was not found."
                return nil
            }
        } else {
            errorString = "No Application Support directory was returned. Exiting."
            return nil
        }
    }
    
    @IBOutlet weak var collectionView: NSScrollView!
    @IBOutlet weak var imageCollectionView: NSCollectionView!
    
    var errorLabel : NSTextView?
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if (errorLabel != nil) {
            self.errorLabel!.removeFromSuperview()
            self.errorLabel = nil
        }
        
        if let files = self.refreshFiles() {
            self.imageCollectionView.isHidden = false
            
            // Silently ignoring the files for which data cannot be loaded
            let imagesAndPaths = files.map { ($0, NSImage(contentsOfFile: $0)) }.filter { $0.1 != nil }.map { ($0.0, $0.1!) }
            
            let contentWidth = self.collectionView.contentSize.width
            let gutter = CGFloat(5)
            
            self.imageCollectionView.minItemSize = NSMakeSize(contentWidth, 1.0 / (16.0 / 10.0) * contentWidth + gutter)
            self.imageCollectionView.itemPrototype = WallpaperItem()
            self.imageCollectionView.isSelectable = true
            self.imageCollectionView.content = imagesAndPaths.map { $0.1 }

            for (idx, imgPathTuple) in imagesAndPaths.enumerated() {
                let item = self.imageCollectionView.item(at: idx) as? WallpaperItem
                item!.setImage(imgPathTuple.1, path: imgPathTuple.0)
            }
        } else {
            self.imageCollectionView.isHidden = true
            let errorLabel = NSTextView(frame: self.collectionView.frame)
            errorLabel.drawsBackground = false
            errorLabel.alignCenter(nil)
            
            if (errorString == nil) {
                errorLabel.string = "Sorry, could not load the wallpapers."
            } else {
                errorLabel.string = errorString!
                print(errorString);
            }
            
            let fontSize = CGFloat(16), contentSize = self.collectionView.contentSize
            errorLabel.frame = NSMakeRect(0, (contentSize.height - fontSize) / 2, contentSize.width, fontSize)
            errorLabel.isEditable = false
            
            self.errorLabel = errorLabel
  
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
    
    func setImage(_ image: NSImage, path: String) {
        self.path = path
        self.wallpaperView!.image = image
    }
    
    override var isSelected : Bool {
        didSet {
            if (isSelected && self.path != nil) {
                print("Showing path: \(self.path)")
                let fileURL = URL(fileURLWithPath: self.path!)
                NSWorkspace.shared().activateFileViewerSelecting([ fileURL ])
            }
        }
    }
}
