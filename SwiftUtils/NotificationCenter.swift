//
//  NotificationCenter.swift
//

// ACTKit ?

import Foundation

// It would be cool if I could get this to work with complete type-safety:
/*public struct NCKey<S: SenderType, K: KeyType, V: ValueType> {
    init(_ name: String) { self.name = name }
    let name: String
}
public struct NCKeys {}
*/

public let NotificationCenter = NotificationCenterClass()

public class NotificationCenterClass {
    
    private var observers = [String:[NotificationObserver]]()
    
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

public class NotificationObserver {
    
    public typealias NotificationBlock = (observer: NotificationObserver, sender: AnyObject?, userInfo: NSDictionary?)->()
    
    private weak var sender: AnyObject?
    private weak var observer: AnyObject?
    private var queue: NSOperationQueue? = NSOperationQueue.mainQueue()
    private var block: NotificationBlock?
    private var filter: (userInfo: NSDictionary?) -> Bool = { _ in true }
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
                let notificationSender: AnyObject? = n.object
                let userInfo = n.userInfo
                
                if let me = self {
                    if let sender: AnyObject = me.sender {
                        if notificationSender == nil { return }
                        if sender !== notificationSender! { return }
                    }
                    
                    if me.observer != nil {
                        if let block = me.block {
                            if me.filter(userInfo: userInfo) {
                                me.dispatch(block: block, sender: notificationSender, userInfo: userInfo)
                            }
                        }
                    }
                    else { me.remove() }
                }
        }
    }
    
    private func dispatch(#block: NotificationBlock, sender: AnyObject?, userInfo: NSDictionary?) {
        block(observer: self, sender: sender, userInfo: userInfo)
        fireCount++
        if let count = maxFireCount {
            if fireCount >= count { remove() }
        }
    }
    
    public func sender(sender: AnyObject?) -> NotificationObserver {
        self.sender = sender
        reloadNotification()
        return self
    }
    
    public func block(block: NotificationBlock) -> NotificationObserver {
        self.block = block
        reloadNotification()
        return self
    }
    
    public func queue(queue: NSOperationQueue?) -> NotificationObserver {
        self.queue = queue
        reloadNotification()
        return self
    }
    
    public func filter(filter: (userInfo: NSDictionary?) -> Bool) -> NotificationObserver {
        self.filter = filter
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
