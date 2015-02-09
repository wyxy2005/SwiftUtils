//
//  UserDefaults.swift
//

import Foundation

private extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    func map <OutKey: Hashable, OutValue>(transform: Element -> (OutKey, OutValue)) -> [OutKey:OutValue] {
        return [OutKey:OutValue](Swift.map(self, transform))
    }
}

public protocol UserDefaultsConvertible {
    typealias UserDefaultsInfoType: _ObjectiveCBridgeable
    init(userDefaultsInfo: UserDefaultsInfoType)
    var userDefaultsInfo: UserDefaultsInfoType { get }
}

// NOTE: When static variables on a generic struct are allowed, then move all UDKeys to UDKey and .MyKey notation will be allowed
public struct UDKeys {}
public struct UDKey <T>  {
    public let name: String // It is a good idea to have the key name be the same as the UDKey variable name to avoid collisions
    public let defaultValue: T
    public init(_ n: String, _ v: T) {
        name = n
        defaultValue = v
    }
}

// NOTE: Subscripts with generics are not yet allowed. When they get implemented, this can be re-written using subscripts
public class UserDefaultsClass {
    private let storage = NSUserDefaults.standardUserDefaults()
    public init(storage: NSUserDefaults) { self.storage = storage }
    public init() {}
    
    // A version of NSCoding for Swift-only objects that instead of coding
    // in raw data actually returns a type that is serializable
    public func get <T: UserDefaultsConvertible>(key: UDKey<T>) -> T {
        if exists(key) {
            return T(userDefaultsInfo: storage.objectForKey(key.name) as T.UserDefaultsInfoType)
        }
        else { return key.defaultValue }
    }
    public func set <T: UserDefaultsConvertible>(key: UDKey<T>, _ value: T) {
        storage.setObject(value.userDefaultsInfo as T.UserDefaultsInfoType._ObjectiveCType, forKey: key.name)
    }
    public func change <T: UserDefaultsConvertible>(key: UDKey<T>, block: (inout value: T)->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    public func get <T: UserDefaultsConvertible>(key: UDKey<[T]>) -> [T] {
        if exists(key) {
            return (storage.objectForKey(key.name) as [T.UserDefaultsInfoType]).map { T(userDefaultsInfo: $0) }
        }
        else { return key.defaultValue }
    }
    public func set <T: UserDefaultsConvertible>(key: UDKey<[T]>, _ value: [T]) {
        let v = value.map { $0.userDefaultsInfo }
        storage.setObject(v, forKey: key.name)
    }
    public func change <T: UserDefaultsConvertible>(key: UDKey<[T]>, block: (inout value: [T])->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    public func get <T: UserDefaultsConvertible>(key: UDKey<[String:T]>) -> [String:T] {
        if exists(key) {
            return (storage.objectForKey(key.name) as [String:T.UserDefaultsInfoType]).map { ($0, T(userDefaultsInfo: $1)) }
        }
        else { return key.defaultValue }
    }
    public func set <T: UserDefaultsConvertible>(key: UDKey<[String:T]>, _ value: [String:T]) {
        let v = value.map { ($0, $1.userDefaultsInfo) }
        storage.setObject(v, forKey: key.name)
    }
    public func change <T: UserDefaultsConvertible>(key: UDKey<[String:T]>, block: (inout value: [String:T])->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    // NSCoding
    public func get <T: NSCoding>(key: UDKey<T>) -> T {
        if exists(key) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(storage.objectForKey(key.name) as NSData) as T
        }
        else { return key.defaultValue }
    }
    public func set <T: NSCoding>(key: UDKey<T>, _ value: T) {
        storage.setObject(NSKeyedArchiver.archivedDataWithRootObject(value), forKey: key.name)
    }
    public func change <T: NSCoding>(key: UDKey<T>, block: (inout value: T)->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    // _ObjectiveCBridgeable
    public func get <T: _ObjectiveCBridgeable>(key: UDKey<T>) -> T {
        if exists(key) {
            return storage.objectForKey(key.name) as T
        }
        else { return key.defaultValue }
    }
    public func set <T: _ObjectiveCBridgeable>(key: UDKey<T>, _ value: T) {
        storage.setObject(value as? T._ObjectiveCType, forKey: key.name)
    }
    public func change <T: _ObjectiveCBridgeable>(key: UDKey<T>, block: (inout value: T)->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    // Other functions
    public func exists <T>(key: UDKey<T>) -> Bool {
        return storage.objectForKey(key.name) != nil
    }
    public func remove <T>(key: UDKey<T>) {
        storage.removeObjectForKey(key.name)
    }
}

/* Usage:

let UserDefaults = UserDefaultsClass()

extension UDKeys {
    static var MyKey = UDKey<[String: [String: [Int]]]>("MyKey", [])
}

let default = UserDefaults.get(UDKeys.MyKey)
UserDefaults.set(UDKeys.MyKey, ["asd": ["45455": [3, 65]]])
let v = UserDefaults.get(UDKeys.MyKey)

*/
