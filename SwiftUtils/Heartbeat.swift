//
//  Heartbeat.swift
//  Clepsydra
//
//  Created by Alexandre on 26/10/14.
//  Copyright (c) 2014 ACT Productions. All rights reserved.
//

import Foundation

/// A simple class for calling a block repeatedly with defined a time interval
public class Heartbeat: NSObject {
    public let timeInterval: Double
    public let action: ()->()
    
    private var timer: NSTimer?
    
    /// Instantiates with the given time interval and action
    /// Does not start automatically
    public init(timeInterval: Double, action: ()->()) {
        self.timeInterval = timeInterval
        self.action = action
    }
    
    /// Instantiates with a time interval 1/beatsPerSecond
    public convenience init(beatsPerSecond: Double, action: ()->()) {
        self.init(timeInterval: 1/beatsPerSecond, action: action)
    }
    
    /// Instantiates with a time interval of one second
    public convenience init(action: ()->()) {
        self.init(timeInterval: 1, action: action)
    }
    
    /// Start beating (forever)
    public func start() {
        stop()
        timer = NSTimer(timeInterval: timeInterval, target: self, selector: "fire", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    /// Stop beating
    public func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    public var running: Bool {
        return timer != nil
    }
    
    public func fire() {
        action()
    }
    
    deinit {
        stop()
    }
}