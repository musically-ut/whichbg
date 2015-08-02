//
//  Core.swift
//  WhichBG
//
//  Created by Utkarsh Upadhyay on 8/2/15.
//  Copyright (c) 2015 Utkarsh Upadhyay. All rights reserved.
//

import Foundation

private let defaultManager = NSFileManager.defaultManager()

func isDir(path: String) -> Bool {
    var isDir : ObjCBool = false
    let exists = defaultManager.fileExistsAtPath(path, isDirectory: &isDir)
    return (exists && isDir)
}

// Returns all "valid" combinations of folders and files passed to it.
func findAllExistingFilesIn(fileFolderList: [String]) ->  [String] {
    // var folders = String[], absFiles = String[], relFiles = [];
    
    let folders = fileFolderList.map({ (x: String) -> String in x.stringByExpandingTildeInPath }).filter(isDir)
    for f in folders {
        println("Folder = \(f)")
    }
    
    return []
}