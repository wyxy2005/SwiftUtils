//
//  UserDefaults.swift
//

import Foundation

/// This is a replacement for NSCoding useful for true Swift classes so that they don't have to become Objective-C objects just to be saved easily on NSUserDefaults
public protocol UserDefaultsConvertible {
    typealias UserDefaultsInfoType: _ObjectiveCBridgeable
    
    /// Create a new instance of the object from the information saved on NSUserDefaults
    init(userDefaultsInfo: UserDefaultsInfoType)
    
    /// The information to be saved to NSUserDefaults. This should be a property list object or else NSUserDefaults will complain
    var userDefaultsInfo: UserDefaultsInfoType { get }
}

/**
A container for all UDKey's in an application. This struct is supposed to be extended with the various keys

Note: when static variables on a generic struct are implemented, then extend UDKey instead and .MyKey notation will be allowed
*/
public struct UDKeys {}

/**
A single NSUserDefaults key wrapper

It is a good idea to have the key name be the same as the UDKey variable name to avoid collisions

:param: T The type of the object stored in this key
:param: name The name of the key used to store the object
:param: defaultValue The default value for the key. This is returned when trying to get a value for this key and the key doesn't yet exist in NSUserDefaults
*/
public struct UDKey <T>  {
    public let name: String
    public let defaultValue: T
    public init(_ n: String, _ v: T) {
        name = n
        defaultValue = v
    }
}


/**
An NSUserDefaults replacement. Uses UDKey for type-safety and default values and supports various storages.

This class supports all objects NSUserDefaults supports, plus objects that conform to NSCoding and UserDefaultsConvertible.

This class should be instantiated once for each storage on a global constant and then used on the entire application:

let UserDefaults = UserDefaultsClass()

[...]

var v = UserDefaults.get(UDKeys.MyKey)

When getting a value for a key (using get), the result is either the value for that key if the key exists on storage or the default value.

Note: Subscripts with generics are not yet allowed. When they get implemented, get/set can be re-written using subscripts and `change` can perhaps disappear.
*/
public class UserDefaultsClass {
    private let storage = NSUserDefaults.standardUserDefaults()
    
    /// Create a new instance with the default storage: NSUserDefaults.standardUserDefaults()
    public init() {}
    
    /// Create a new instance with the given storage
    public init(storage: NSUserDefaults) { self.storage = storage }

    // MARK: UserDefaultsConvertible
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
    
    // MARK: NSCoding
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
    
    // MARK: _ObjectiveCBridgeable
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
    
    // MARK: Other functions
    
    /// Check if key exists on storage
    public func exists <T>(key: UDKey<T>) -> Bool {
        return storage.objectForKey(key.name) != nil
    }
    
    /// Remove key from storage
    public func remove <T>(key: UDKey<T>) {
        storage.removeObjectForKey(key.name)
    }
}

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
