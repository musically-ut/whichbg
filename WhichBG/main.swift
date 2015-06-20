//
//  main.swift
//  WhichBG
//
//  Created by Utkarsh Upadhyay on 6/20/15.
//  Copyright (c) 2015 Utkarsh Upadhyay. All rights reserved.
//

import Cocoa

// Providing an entry point to the application without using Storyboards
//

var delegate = AppDelegate()
NSApplication.sharedApplication().delegate = delegate;
NSApplicationMain(Process.argc, Process.unsafeArgv);
