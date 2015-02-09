//
//  Heartbeat.swift
//  Clepsydra
//
//  Created by Alexandre on 26/10/14.
//  Copyright (c) 2014 ACT Productions. All rights reserved.
//

import Foundation

public class Heartbeat: NSObject {
    public let timeInterval: Double
    public let action: ()->()
    
    private var timer: NSTimer?
    
    public init(timeInterval: Double, action: ()->()) {
        self.timeInterval = timeInterval
        self.action = action
    }
    
    public convenience init(beatsPerSecond: Double, action: ()->()) {
        self.init(timeInterval: 1/beatsPerSecond, action: action)
    }
    
    public convenience init(action: ()->()) {
        self.init(timeInterval: 1, action: action)
    }
    
    public func start() {
        stop()
        timer = NSTimer(timeInterval: timeInterval, target: self, selector: "fire", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
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