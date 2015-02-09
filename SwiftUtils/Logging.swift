//
//  Logging.swift
//

public func p<T>(object: T, _ file: String = __FILE__, _ function: String = __FUNCTION__, _ line: Int = __LINE__) {
    let filename = file.lastPathComponent.stringByDeletingPathExtension
    
    let df = NSDateFormatter()
    df.dateStyle = .ShortStyle
    df.timeStyle = .MediumStyle
    
    let ti = NSDate().timeIntervalSinceReferenceDate
    let date = NSString(format: "%@.%04d", df.stringFromDate(NSDate()), Int((ti - floor(ti))*10000))
    println("\(date) - \(filename).\(function)[\(line)]: \(object)")
}

public func p(_ file: String = __FILE__, _ function: String = __FUNCTION__, _ line: Int = __LINE__) {
    let filename = file.lastPathComponent.stringByDeletingPathExtension
    
    let df = NSDateFormatter()
    df.dateStyle = .ShortStyle
    df.timeStyle = .MediumStyle
    
    let ti = NSDate().timeIntervalSinceReferenceDate
    let date = NSString(format: "%@.%04d", df.stringFromDate(NSDate()), Int((ti - floor(ti))*10000))
    println("\(date) - \(filename).\(function)[\(line)]")
}
