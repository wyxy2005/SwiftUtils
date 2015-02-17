//
//  Event.swift
//

// Note: from https://github.com/artman/Signals

import Foundation

/// Create instances of Event and assign them to public constants on your class for each event type that can
/// be observed by listeners.
public class Event<T> {
    
    /// The number of times the event has fired.
    public var fireCount: Int
    
    /// The last data that the event was fired with.
    public var lastDataFired: T? = nil
    
    /// All the listeners listening to the Event.
    public var listeners: [AnyObject] {
        return eventListeners
            .filter { $0.listener != nil }
            .map { $0.listener! }
    }
    
    public init() {
        fireCount = 0
    }
    
    private var eventListeners = [EventListener<T>]()
    
    private func dumpCancelledListeners() {
        var removeListeners = false
        for eventListener in eventListeners {
            if eventListener.listener == nil {
                removeListeners = true
            }
        }
        if removeListeners {
            eventListeners = eventListeners.filter {
                if let definiteListener: AnyObject = $0.listener {
                    return true
                }
                return false
            }
        }
    }
    
    /// Attaches a listener to the event
    ///
    /// :param: listener The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// :param: callback The closure to invoke whenever the event fires.
    public func listen(listener: AnyObject, callback: (T) -> Void) -> EventListener<T> {
        dumpCancelledListeners()
        var eventListener = EventListener<T>(listener: listener, callback: callback);
        eventListeners.append(eventListener)
        return eventListener
    }
    
    /// Attaches a listener to the event that is removed after the event has fired once
    ///
    /// :param: listener The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// :param: callback The closure to invoke when the event fires for the first time.
    public func listenOnce(listener: AnyObject, callback: (T) -> Void) -> EventListener<T> {
        var eventListener = self.listen(listener, callback: callback)
        eventListener.once = true
        return eventListener
    }
    
    /// Attaches a listener to the event and invokes the callback immediately with the last data fired by the event
    /// if it has fired at least once.
    ///
    /// :param: listener The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// :param: callback The closure to invoke whenever the event fires.
    public func listenPast(listener: AnyObject, callback: (T) -> Void) -> EventListener<T> {
        var eventListener = self.listen(listener, callback: callback)
        if fireCount > 0 {
            eventListener.callback(lastDataFired!)
        }
        return eventListener
    }
    
    /// Fires the singal.
    ///
    /// :param: data The data to fire the event with.
    public func fire(data: T) {
        fireCount++
        lastDataFired = data
        dumpCancelledListeners()
        
        var index = 0
        
        for eventListener in eventListeners {
            if eventListener.filter == nil || eventListener.filter!(data) == true {
                if !eventListener.dispatch(data) {
                    eventListeners.removeAtIndex(index--)
                }
                index++
            }
        }
    }
    
    /// Removes an object as a listener of the Event.
    ///
    /// :param: listener The listener to remove.
    public func removeListener(listener: AnyObject) {
        eventListeners = eventListeners.filter {
            if let definiteListener:AnyObject = $0.listener {
                return definiteListener.hash != listener.hash
            }
            return false
        }
    }
    
    /// Removes all listeners from the Event
    public func removeAllListeners() {
        eventListeners.removeAll(keepCapacity: false)
    }
}

/// A EventLister represenents an instance and its association with a Event.
public class EventListener<T> {
    
    // The listener
    weak public var listener: AnyObject?
    
    /// Whether the listener should be removed once it observes the Event firing once
    public var once = false
    
    private var delay: NSTimeInterval?
    private var queuedData: T?
    private var filter: ((T) -> Bool)?
    private var callback: (T) -> Void
    
    private init (listener: AnyObject, callback: (T) -> Void) {
        self.listener = listener
        self.callback = callback
    }
    
    private func dispatch(data: T) -> Bool {
        if listener != nil {
            if once {
                listener = nil
            }
            
            if delay != nil {
                if queuedData != nil {
                    // Already queueing
                    queuedData = data
                } else {
                    // Set up queue
                    queuedData = data
                    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(delay! * Double(NSEC_PER_SEC))),
                        dispatch_get_main_queue()) { [weak self] () -> Void in
                            if let definiteSelf = self {
                                let data = definiteSelf.queuedData!
                                definiteSelf.queuedData = nil
                                if definiteSelf.listener != nil {
                                    definiteSelf.callback(data)
                                }
                            }
                    }
                    
                }
            } else {
                callback(data)
            }
        }
        return listener != nil
    }
    
    /// Assigns a filter to the EventListener. This lets you define conditions under which a listener should actually
    /// receive the firing of a Singal. The closure that is passed an argument can decide whether the firing of a Event
    /// should actually be dispatched to its listener depending on the data fired.
    ///
    /// If the closeure returns true, the listener is informed of the fire. The default implementation always
    /// returns true.
    ///
    /// :param: filter A closure that can decide whether the Event fire should be dispatched to its listener.
    /// :return: Returns self so you can chain calls.
    public func filter(filter: (T) -> Bool) -> EventListener {
        self.filter = filter
        return self
    }
    
    /// Tells the listener to queue up all event fires until the elapsed time has passed and only once dispatch the last received
    /// data. A delay of 0 will wait until the next runloop to dispatch the event fire to the listener.
    /// :param: delay The number of seconds to delay dispatch
    /// :return: Returns self so you can chain calls.
    public func queueAndDelayBy(delay: NSTimeInterval) -> EventListener {
        self.delay = delay
        return self
    }
    
    /// Cancels the listener. This will detach the listening object from the Event.
    public func cancel() {
        self.listener = nil
    }
}
