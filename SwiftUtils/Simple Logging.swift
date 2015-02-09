//
//  Simple Logging.swift
//

private func loggingDateFormat() -> String {
    let df = NSDateFormatter()
    df.dateStyle = .ShortStyle
    df.timeStyle = .MediumStyle
    
    let ti = NSDate().timeIntervalSinceReferenceDate
    return NSString(format: "%@.%04d", df.stringFromDate(NSDate()), Int((ti - floor(ti))*10000))
}

/// Log the date, file, function, line number, textual representation of `object` and a newline character into the standard output
public func p<T>(object: T, _ file: String = __FILE__, _ function: String = __FUNCTION__, _ line: Int = __LINE__) {
    let filename = file.lastPathComponent.stringByDeletingPathExtension
    println("\(loggingDateFormat()) - \(filename).\(function)[\(line)]: \(object)")
}

/// Log the date, file, function, line number and a newline character into the standard output
public func p(_ file: String = __FILE__, _ function: String = __FUNCTION__, _ line: Int = __LINE__) {
    let filename = file.lastPathComponent.stringByDeletingPathExtension
    println("\(loggingDateFormat()) - \(filename).\(function)[\(line)]")
}

