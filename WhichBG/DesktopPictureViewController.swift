//
//  DesktopPictureViewController.swift
//  WhichBG
//
//  Created by Utkarsh Upadhyay on 8/3/15.
//  Copyright (c) 2015 Utkarsh Upadhyay. All rights reserved.
//

import Cocoa

class DesktopPictureViewController: NSViewController {

    @IBAction func Exitaction(sender: NSButton) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBOutlet weak var collectionView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
