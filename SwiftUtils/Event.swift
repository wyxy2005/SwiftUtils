//
//  Event.swift
//

// Note: adapted from https://github.com/artman/Signals

import Foundation

public func ==(l: None, r: None) -> Bool { return true }
public struct None: NilLiteralConvertible, Hashable, Equatable {
    public init(nilLiteral: Void) {}
    public var hashValue: Int { return 0 }
}

public class Event<T> {
    private var eventListeners = [EventListener<T>]()
    
    /*public class func listenAny<T>(listener: AnyObject, _ events: Event<T>...) -> EventListener<T> {
    let eventListener = EventListener<T>(listener: listener)
    for event in events { event.addListener(eventListener) }
    return eventListener
    }
    public class func listenAny(listener: AnyObject, events: [Event<Any>]) -> EventListener<Any> {
    let eventListener = EventListener<Any>(listener: listener)
    for event in events { event.addListener(eventListener) }
    return eventListener
    }*/
    
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
    
    public init() {}
    
    public func listen(listener: AnyObject) -> EventListener<T> {
        return addListener(EventListener<T>(listener: listener))
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
    private var callback: EventCallback<T>?
    private var queue: dispatch_queue_t? = dispatch_get_main_queue()
    private var addedToQueue = false
    private var maxFireCount: Int?
    
    private init(listener: AnyObject) {
        self.listener = listener
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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), queue ?? DISPATCH_CURRENT_QUEUE_LABEL) { [weak self] in
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
            dispatch_async(queue ?? DISPATCH_CURRENT_QUEUE_LABEL) { [weak self] in
                self?.callWithData(newData); return
            }
        }
        
        fireCount++
        if let count = maxFireCount {
            if fireCount >= count { listener = nil }
        }
    }
    
    private func callWithData(data: T) {
        if let callback = callback {
            switch callback {
            case .Type1(let f): f()
            case .Type2(let f): f(data)
            case .Type3(let f): f(data, self)
            }
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
    
    public func accumulate(accumulator: (oldData: T, justArrived: T) -> T) -> EventListener<T> {
        self.accumulator = accumulator
        return self
    }
    
    public func action(callback: () -> ()) -> EventListener<T> {
        self.callback = .Type1(callback)
        return self
    }
    public func action(callback: (data: T) -> ()) -> EventListener<T> {
        self.callback = .Type2(callback)
        return self
    }
    public func action(callback: (T, EventListener<T>) -> ()) -> EventListener<T> {
        self.callback = .Type3(callback)
        return self
    }
    
    public func queue(queue: dispatch_queue_t?) -> EventListener<T> {
        self.queue = queue
        return self
    }
    
    public func fire(data: T) -> EventListener<T>  {
        callWithData(data)
        return self
    }
    public func fire() -> EventListener<T>  {
        if let callback = callback {
            switch callback {
            case .Type1(let f): f()
            default: assertionFailure("fire() called (with no data) on EventListener whose action block takes data")
            }
        }
        return self
    }
    
    public func resetAccumulator() {
        savedData = nil
    }
    public func cancel() {
        listener = nil
    }
}