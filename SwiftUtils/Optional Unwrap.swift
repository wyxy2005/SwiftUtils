//
//  Optional Unwrap.swift
//  

// Note: taken from https://gist.github.com/tomlokhorst/f9a826bf24d16cb5f6a3

/// if let (A, B) = unwrap(optA, optB) { ... }
public func unwrap<T1, T2>(optional1: T1?, optional2: T2?) -> (T1, T2)? {
    switch (optional1, optional2) {
    case let (.Some(value1), .Some(value2)):
        return (value1, value2)
    default:
        return nil
    }
}

/// if let (A, B, C) = unwrap(optA, optB, optC) { ... }
public func unwrap<T1, T2, T3>(optional1: T1?, optional2: T2?, optional3: T3?) -> (T1, T2, T3)? {
    switch (optional1, optional2, optional3) {
    case let (.Some(value1), .Some(value2), .Some(value3)):
        return (value1, value2, value3)
    default:
        return nil
    }
}

/// if let (A, B, C, D) = unwrap(optA, optB, optC, optD) { ... }
public func unwrap<T1, T2, T3, T4>(optional1: T1?, optional2: T2?, optional3: T3?, optional4: T4?) -> (T1, T2, T3, T4)? {
    switch (optional1, optional2, optional3, optional4) {
    case let (.Some(value1), .Some(value2), .Some(value3), .Some(value4)):
        return (value1, value2, value3, value4)
    default:
        return nil
    }
}
