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

func isFile(path: String) -> Bool {
    var isDir : ObjCBool = false
    let exists = defaultManager.fileExistsAtPath(path, isDirectory: &isDir)
    return (exists && !isDir)
}

// Returns all "valid" combinations of folders and files passed to it.
func findAllExistingFilesIn(fileFolderList: [String]) ->  [String] {
    var folders : [String] = [], absFiles : [String] = [], relFiles : [String] = [];
    
    let fullFileFolders = fileFolderList.map({ ($0 as NSString).stringByExpandingTildeInPath })
    
    for fileFolder in fullFileFolders {
        if isDir(fileFolder) {
            folders.append(fileFolder)
        } else if isFile(fileFolder) {
            absFiles.append(fileFolder)
        } else {
            relFiles.append(fileFolder)
        }
    }
    
    var allFiles = absFiles
    
    for folder in folders {
        for file in relFiles {
            let fileAbsPath = (folder as NSString).stringByAppendingPathComponent(file)
            if isFile(fileAbsPath) {
                allFiles.append(fileAbsPath)
            }
        }
    }
    
    return allFiles
}