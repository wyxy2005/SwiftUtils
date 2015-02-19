//
//  Interface Events.swift
//

import UIKit

private let UIControlEventsMapTableStorage = NSMapTable.weakToStrongObjectsMapTable() // [UIControl : [UIControlEventClass : EventObjcWrapper]]

private class UIControlEventsClass: Hashable, Equatable {
    let event: UIControlEvents
    var hashValue: Int { return Int(event.rawValue) }
    init(_ e: UIControlEvents) { event = e }
}

@objc private class EventObjcWrapper: NSObject {
    let event: Event<AnyObject>
    @objc func fire(sender: AnyObject) { event.fire(sender) }
    init(_ e: Event<AnyObject>) { event = e }
}

private func ==(l: UIControlEventsClass, r: UIControlEventsClass) -> Bool { return l.event == r.event }

private func setupEvent<T: UIControl>(control: T, controlEvents: UIControlEvents) -> Event<T> {
    typealias StorageValue = [UIControlEventsClass: EventObjcWrapper]
    
    var dict: StorageValue
    if let d: AnyObject = UIControlEventsMapTableStorage.objectForKey(control) {
        dict = d as StorageValue
    }
    else {
        dict = StorageValue()
        UIControlEventsMapTableStorage.setObject(dict, forKey: control)
    }
    
    var eventWrapper: EventObjcWrapper
    if let e = dict[UIControlEventsClass(controlEvents)] {
        eventWrapper = e
    }
    else {
        let event = Event<T>()
        eventWrapper = EventObjcWrapper(unsafeBitCast(event, Event<AnyObject>.self))
        
        dict[UIControlEventsClass(controlEvents)] = eventWrapper
        UIControlEventsMapTableStorage.setObject(dict, forKey: control)
    }
    
    control.addTarget(eventWrapper, action: "fire:", forControlEvents: controlEvents)
    return unsafeBitCast(eventWrapper.event, Event<T>.self)
}

public extension UIButton {
    public func event(controlEvents: UIControlEvents) -> Event<UIButton> {
        return setupEvent(self, controlEvents)
    }
}
public extension UIDatePicker {
    public func event(controlEvents: UIControlEvents) -> Event<UIDatePicker> {
        return setupEvent(self, controlEvents)
    }
}
public extension UIPageControl {
    public func event(controlEvents: UIControlEvents) -> Event<UIPageControl> {
        return setupEvent(self, controlEvents)
    }
}
public extension UIRefreshControl {
    public func event(controlEvents: UIControlEvents) -> Event<UIRefreshControl> {
        return setupEvent(self, controlEvents)
    }
}
public extension UISegmentedControl {
    public func event(controlEvents: UIControlEvents) -> Event<UISegmentedControl> {
        return setupEvent(self, controlEvents)
    }
}
public extension UISlider {
    public func event(controlEvents: UIControlEvents) -> Event<UISlider> {
        return setupEvent(self, controlEvents)
    }
}
public extension UIStepper {
    public func event(controlEvents: UIControlEvents) -> Event<UIStepper> {
        return setupEvent(self, controlEvents)
    }
}
public extension UISwitch {
    public func event(controlEvents: UIControlEvents) -> Event<UISwitch> {
        return setupEvent(self, controlEvents)
    }
}
public extension UITextField {
    public func event(controlEvents: UIControlEvents) -> Event<UITextField> {
        return setupEvent(self, controlEvents)
    }
}
