//
//  GlobalEventMonitor.swift
//  WhichBG
//
//  Created by Utkarsh Upadhyay on 8/4/15.
//  Copyright (c) 2015 Utkarsh Upadhyay. All rights reserved.
//

import Cocoa

open class GlobalEventMonitor {
    fileprivate var monitor: AnyObject?
    fileprivate let mask: NSEventMask
    fileprivate let handler: (NSEvent?) -> ()
    
    public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    open func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject?
    }
    
    open func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
