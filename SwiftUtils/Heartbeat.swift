//
//  Heartbeat.swift
//  

import Foundation

/**
A simple class for calling a block repeatedly with defined a time interval
*/
public class Heartbeat: NSObject {
    public let timeInterval: Double
    public let action: ()->()
    
    private var timer: NSTimer?
    
    /**
    Instantiates with the given time interval and action
    Does not start automatically
    
    :param: timeInterval The time interval between two calls of action
    :param: action       The block to run
    */
    public init(timeInterval: Double, action: ()->()) {
        self.timeInterval = timeInterval
        self.action = action
    }
    
    /**
    Instantiates with a time interval equal to 1/beatsPerSecond
    */
    public convenience init(beatsPerSecond: Double, action: ()->()) {
        self.init(timeInterval: 1/beatsPerSecond, action: action)
    }
    
    /**
    Instantiates with a time interval of one second
    */
    public convenience init(action: ()->()) {
        self.init(timeInterval: 1, action: action)
    }
    
    /**
    Start beating (forever)
    */
    public func start() {
        stop()
        timer = NSTimer(timeInterval: timeInterval, target: self, selector: "fire", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    /**
    Stop beating
    */
    public func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    public var running: Bool {
        return timer != nil
    }
    
    @objc private func fire() {
        action()
    }
    
    deinit {
        stop()
    }
}