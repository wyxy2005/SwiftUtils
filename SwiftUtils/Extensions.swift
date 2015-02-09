//
//  NSURL.swift
//  Clepsydra
//
//  Created by Alexandre on 01/02/15.
//  Copyright (c) 2015 ACT Productions. All rights reserved.
//

import Foundation

public extension String {
    public var stringByDecodingURLFormat: String {
        return self.stringByReplacingOccurrencesOfString("+", withString: " ").stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    public var stringByEncodingURLFormat: String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "+").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    public func split(s: String) -> [String] {
        return self.componentsSeparatedByString(s)
    }
    
    public subscript (i: Int) -> Character {
        return self[advance(startIndex, i)]
    }
    
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    public subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

public extension NSIndexPath {
    public convenience init(_ section: Int, _ row: Int) {
        self.init(forRow: row, inSection: section)
    }
}

public extension Int {
    public init?(_ string: String) {
        if let i = string.toInt() { self = i }
        else { return nil }
    }
}

public extension Bool {
    public init?(_ string: String) {
        if let i = Int(string) { self = i != 0 }
        else { return nil }
    }
}

public extension NSURL {
    public var queryDictionary: [String:[String]] {
        var queryDict = [String:[String]]()
        
        if let query = self.query {
            for string in query.split("&") {
                let keyValuePair = string.split("=")
                if keyValuePair.count < 2 { continue }
                
                let key = keyValuePair[0].stringByDecodingURLFormat
                let value = keyValuePair[1].stringByDecodingURLFormat
                
                if queryDict[key] == nil { queryDict[key] = [] }
                queryDict[key]!.append(value)
            }
            
            return queryDict
        }
        else { return [:] }
    }
}

extension NSDate: Comparable {}
public func == (a: NSDate, b: NSDate) -> Bool {
    return a.isEqualToDate(b)
}
public func < (a: NSDate, b: NSDate) -> Bool {
    return a.earlierDate(b) == a
}

public extension NSDateComponents {
    public var inverted: NSDateComponents {
        let cal = NSCalendar.autoupdatingCurrentCalendar()
        let d1 = NSDate()
        let d2 = cal.dateByAddingComponents(self, toDate: d1, options: NSCalendarOptions.allZeros)!
        return cal.components(NSDateComponents.allUnits, fromDate: d2, toDate: d1, options: NSCalendarOptions.allZeros)
    }
    
    public class var allUnits: NSCalendarUnit {
        return NSCalendarUnit.CalendarUnitEra |
            NSCalendarUnit.CalendarUnitYear |
            NSCalendarUnit.CalendarUnitMonth |
            NSCalendarUnit.CalendarUnitDay |
            NSCalendarUnit.CalendarUnitHour |
            NSCalendarUnit.CalendarUnitMinute |
            NSCalendarUnit.CalendarUnitSecond |
            NSCalendarUnit.CalendarUnitWeekday |
            NSCalendarUnit.CalendarUnitWeekdayOrdinal |
            NSCalendarUnit.CalendarUnitQuarter |
            NSCalendarUnit.CalendarUnitWeekOfMonth |
            NSCalendarUnit.CalendarUnitWeekOfYear |
            NSCalendarUnit.CalendarUnitYearForWeekOfYear |
            NSCalendarUnit.CalendarUnitNanosecond |
            NSCalendarUnit.CalendarUnitCalendar |
            NSCalendarUnit.CalendarUnitTimeZone
    }
}
