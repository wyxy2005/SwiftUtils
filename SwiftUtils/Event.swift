//
//  Event.swift
//

// Note: adapted from https://github.com/artman/Signals

import Foundation

public class Event<T> {
    private var eventListeners = [EventListener<T>]()
    
    public var fireCount = 0
    public var listeners: [AnyObject] {
        return eventListeners
            .filter { $0.listener != nil }
            .map { $0.listener! }
    }
    
    private func filterCancelledListeners() {
        eventListeners = eventListeners.filter { $0.listener != nil }
    }
    private func addListener(listener: EventListener<T>) -> EventListener<T> {
        filterCancelledListeners()
        eventListeners.append(listener)
        return listener
    }
    
    public func listen(listener: AnyObject, callback: () -> ()) -> EventListener<T> {
        return addListener(EventListener<T>(listener: listener, callback: .Type1(callback)))
    }
    public func listen(listener: AnyObject, callback: (T) -> ()) -> EventListener<T> {
        return addListener(EventListener<T>(listener: listener, callback: .Type2(callback)))
    }
    public func listen(listener: AnyObject, callback: (T, EventListener<T>) -> ()) -> EventListener<T> {
        return addListener(EventListener<T>(listener: listener, callback: .Type3(callback)))
    }
    
    public func fire(data: T) {
        fireCount++
        filterCancelledListeners()
        
        for eventListener in eventListeners {
            eventListener.dispatch(data)
        }
        
        filterCancelledListeners()
    }
    
    public func removeListener(listener: AnyObject) {
        eventListeners = eventListeners.filter {
            if let l: AnyObject = $0.listener { return l === listener }
            return false
        }
    }
    public func removeAllListeners() {
        eventListeners.removeAll(keepCapacity: false)
    }
}

private enum EventCallback<T> {
    case Type1(() -> ())
    case Type2((T) -> ())
    case Type3((T, EventListener<T>) -> ())
}

public class EventListener<T> {
    
    weak public var listener: AnyObject?
    public var fireCount = 0
    
    private var delay: NSTimeInterval?
    private var savedData: T?
    private var accumulator: ((oldData: T, justArrived: T) -> T) = { $1 }
    private var filter: (T -> Bool)?
    private var callback: EventCallback<T>
    private var addedToQueue = false
    private var maxFireCount: Int?
    
    private init (listener: AnyObject, callback: EventCallback<T>) {
        self.listener = listener
        self.callback = callback
    }
    
    private func dispatch(var newData: T) {
        if listener == nil { return }
        
        if let filter = filter {
            if !filter(newData) { return }
        }
        
        if let savedData = savedData {
            newData = accumulator(oldData: savedData, justArrived: newData)
        }
        
        savedData = newData
        
        if let delay = delay {
            if !addedToQueue {
                addedToQueue = true
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [weak self] in
                    if let me = self {
                        me.addedToQueue = false
                        
                        if let data = me.savedData {
                            if me.listener != nil { me.callWithData(newData) }
                        }
                    }
                }
            }
        }
        else {
            callWithData(newData)
        }
        
        fireCount++
        if let count = maxFireCount {
            if fireCount >= count { listener = nil }
        }
    }
    
    private func callWithData(data: T) {
        switch callback {
        case .Type1(let f): f()
        case .Type2(let f): f(data)
        case .Type3(let f): f(data, self)
        }
    }
    
    public func maxFireCount(count: Int) -> EventListener<T> {
        self.maxFireCount = count
        return self
    }
    public func once() -> EventListener<T> {
        self.maxFireCount = 1
        return self
    }
    public func forever() -> EventListener<T> {
        self.maxFireCount = nil
        return self
    }
    
    public func filter(filter: T -> Bool) -> EventListener<T> {
        self.filter = filter
        return self
    }
    
    public func delay(delay: NSTimeInterval) -> EventListener<T> {
        self.delay = delay
        return self
    }
    
    // choose queue
    
    public func accumulate(accumulator: (oldData: T, justArrived: T) -> T) -> EventListener<T> {
        self.accumulator = accumulator
        return self
    }
    
    public func reset() {
        savedData = nil
    }
    public func cancel() {
        listener = nil
    }
}


