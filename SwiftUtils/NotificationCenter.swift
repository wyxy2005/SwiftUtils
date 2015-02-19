//
//  NotificationCenter.swift
//

import Foundation

// It would be cool if I could get this to work with complete type-safety:
/*public struct NCKey<S: SenderType, K: KeyType, V: ValueType> {
    init(_ name: String) { self.name = name }
    let name: String
}
public struct NCKeys {}
*/
// It's probably not that important though. For type safety use the Event class

public let NotificationCenter = NotificationCenterClass()

public class NotificationCenterClass {
    
    private var center = NSNotificationCenter.defaultCenter()
    private var observers = [String:[NotificationObserver]]()
    
    init() {}
    init(notificationCenter: NSNotificationCenter) {
        center = notificationCenter
    }
    
    private func dumpNotificationObserver(toRemove: NotificationObserver) {
        let observersForKey = observers[toRemove.key]!
        
        var index: Int?
        for (i, observer) in enumerate(observersForKey) {
            if observer === toRemove { index = i }
        }
        
        if let index = index {
            observers[toRemove.key]!.removeAtIndex(index)
        }
    }
    private func remove(observer toRemove: AnyObject, forKey key: String) {
        let observersForKey = observers[key]!
        
        var index: Int?
        for (i, obs) in enumerate(observersForKey) {
            if let observer: AnyObject = obs.observer {
                if observer === toRemove { index = i }
            }
        }
        
        if let index = index {
            observers[key]!.removeAtIndex(index)
        }
    }
    
    public func observe(observer: AnyObject, _ key: String) -> NotificationObserver {
        let notificationObserver = NotificationObserver(observer: observer, key: key)
        
        if observers[key] == nil { observers[key] = [] }
        observers[key]! += [notificationObserver]
        
        return notificationObserver
    }
    
    public func post(key: String, _ sender: AnyObject?, _ userInfo: NSDictionary?) {
        NSNotificationCenter.defaultCenter().postNotificationName(key, object: sender, userInfo: userInfo)
    }
    
    public func remove(observer: AnyObject, _ key: String) {
        remove(observer: observer, forKey: key)
    }
    public func remove(observer: AnyObject) {
        for key in observers.keys {
            remove(observer: observer, forKey: key)
        }
    }
}

private enum NotificationCallback {
    case Type1(() -> ())
    case Type2((sender: AnyObject?) -> ())
    case Type3((sender: AnyObject?, userInfo: NSDictionary?) -> ())
    case Type4((observer: NotificationObserver, sender: AnyObject?, userInfo: NSDictionary?) -> ())
}

private enum NotificationFilter {
    case Type1((userInfo: NSDictionary?) -> Bool)
    case Type2((sender: AnyObject?, userInfo: NSDictionary?) -> Bool)
}

public class NotificationObserver {
    
    private weak var sender: AnyObject?
    private weak var observer: AnyObject?
    private var queue: NSOperationQueue? = NSOperationQueue.mainQueue()
    private var block: NotificationCallback?
    private var filter: NotificationFilter = .Type1({ _ in true })
    private var notificationObject: NSObjectProtocol?
    private var maxFireCount: Int?
    
    public var fireCount = 0
    public let key: String
    
    private init(observer: AnyObject, key: String) {
        self.observer = observer
        self.key = key
    }
    
    deinit {
        if let obj = notificationObject { NSNotificationCenter.defaultCenter().removeObserver(obj) }
    }
    
    private func reloadNotification() {
        if let obj = notificationObject { NSNotificationCenter.defaultCenter().removeObserver(obj) }
        notificationObject = NSNotificationCenter
            .defaultCenter()
            .addObserverForName(key, object: sender, queue: queue) { [weak self] n in
                self?.notificationFired(sender: n.object, userInfo: n.userInfo); return
        }
    }
    
    private func notificationFired(sender notificationSender: AnyObject?, userInfo: NSDictionary?) {
        if let sender: AnyObject = self.sender {
            if notificationSender == nil { return }
            if notificationSender! !== sender { return }
        }
        
        if observer != nil {
            if let block = block {
                if callFilter(sender: sender, userInfo: userInfo) {
                    dispatch(block: block, sender: notificationSender, userInfo: userInfo)
                }
            }
        }
        else { remove() }
    }
    
    private func callFilter(#sender: AnyObject?, userInfo: NSDictionary?) -> Bool {
        switch filter {
        case .Type1(let f): return f(userInfo: userInfo)
        case .Type2(let f): return f(sender: sender, userInfo: userInfo)
        }
    }
    
    private func dispatch(#block: NotificationCallback, sender: AnyObject?, userInfo: NSDictionary?) {
        switch block {
        case .Type1(let f): f()
        case .Type2(let f): f(sender: sender)
        case .Type3(let f): f(sender: sender, userInfo: userInfo)
        case .Type4(let f): f(observer: self, sender: sender, userInfo: userInfo)
        }
        
        fireCount++
        if let count = maxFireCount {
            if fireCount >= count { remove() }
        }
    }
    
    public func action(block: () -> ()) -> NotificationObserver {
        self.block = .Type1(block)
        reloadNotification()
        return self
    }
    public func action(block: (sender: AnyObject?) -> ()) -> NotificationObserver {
        self.block = .Type2(block)
        reloadNotification()
        return self
    }
    public func action(block: (sender: AnyObject?, userInfo: NSDictionary?) -> ()) -> NotificationObserver {
        self.block = .Type3(block)
        reloadNotification()
        return self
    }
    public func action(block: (observer: NotificationObserver, sender: AnyObject?, userInfo: NSDictionary?) -> ()) -> NotificationObserver {
        self.block = .Type4(block)
        reloadNotification()
        return self
    }
    
    public func sender(sender: AnyObject?) -> NotificationObserver {
        self.sender = sender
        reloadNotification()
        return self
    }
    
    public func queue(queue: NSOperationQueue?) -> NotificationObserver {
        self.queue = queue
        reloadNotification()
        return self
    }
    
    public func filter(filter: (userInfo: NSDictionary?) -> Bool) -> NotificationObserver {
        self.filter = .Type1(filter)
        return self
    }
    public func filter(filter: (sender: AnyObject?, userInfo: NSDictionary?) -> Bool) -> NotificationObserver {
        self.filter = .Type2(filter)
        return self
    }
    
    public func maxFireCount(count: Int) -> NotificationObserver {
        self.maxFireCount = count
        return self
    }
    public func once() -> NotificationObserver {
        self.maxFireCount = 1
        return self
    }
    public func forever() -> NotificationObserver {
        self.maxFireCount = nil
        return self
    }
    
    public func remove() {
        NotificationCenter.dumpNotificationObserver(self)
    }
}
