//
//  UserDefaults.swift
//

import Foundation

/// NSUserDefaults only accepts property list objects. This serves as a reminder for that
public typealias PropertyList = _ObjectiveCBridgeable

/// This is a replacement for NSCoding useful for true Swift classes so that they don't have to become Objective-C objects just to be saved easily on NSUserDefaults
public protocol UserDefaultsConvertible {
    typealias UserDefaultsInfoType: PropertyList
    
    /// Create a new instance of the object from the information saved on NSUserDefaults
    init(userDefaultsInfo: UserDefaultsInfoType)
    
    /// The information to be saved to NSUserDefaults. This should be a property list object or else NSUserDefaults will complain
    var userDefaultsInfo: UserDefaultsInfoType { get }
}

/// A container for all UDKey's in an application. This struct is supposed to be extended with the various keys
///
/// Note: when static variables on a generic struct are implemented, then extend UDKey instead and .MyKey notation will be allowed
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
    public let iCloudSync = false
    public init(_ n: String, _ v: T) {
        name = n
        defaultValue = v
    }
    public init(_ n: String, _ v: T, _ c: Bool) {
        name = n
        defaultValue = v
        iCloudSync = c
    }
}

//public let iCloudStorageChangedDiskStorageNotification = "UserDefaultsClass.iCloudStorageChangedDiskStorageNotification"

/**
An NSUserDefaults replacement. Uses UDKey for type-safety and default values and supports various storages.

This class supports all objects NSUserDefaults supports, plus objects that conform to NSCoding and UserDefaultsConvertible.

This class should be instantiated once for each storage on a global constant and then used on the entire application:

`let UserDefaults = UserDefaultsClass()

[...]

var v = UserDefaults.get(UDKeys.MyKey)`

When getting a value for a key (using get), the result is either the value for that key if the key exists on storage or the default value.

Note: Subscripts with generics are not yet allowed. When they get implemented, get/set can be re-written using subscripts and `change` can perhaps disappear.
*/
public class UserDefaultsClass {
    // MARK: Vars
    public var iCloudSync: Bool { didSet { setupCloudSync() } }
    private let diskStorage: NSUserDefaults
    
    public struct Signals {
        public static let diskStorageChanged = Event<UserDefaultsClass>()
        public static let cloudStorageUpdatedDiskStorage = Event<UserDefaultsClass>()
    }
    
    private let iCloudStorage = NSUbiquitousKeyValueStore.defaultStore()
    private let timestampKey = "_CloudKeysLastChangedTimestamp"
    private var iCloudNotification: NSObjectProtocol?
    private var diskNotification: NSObjectProtocol?
    
    // MARK: Init/Deinit
    public convenience init() {
        self.init(iCloudSync: false)
    }
    public convenience init(storage: NSUserDefaults) {
        self.init(storage: storage, iCloudSync: false)
    }
    public convenience init(iCloudSync: Bool) {
        self.init(storage: NSUserDefaults.standardUserDefaults(), iCloudSync: iCloudSync)
    }
    public init(storage: NSUserDefaults, iCloudSync: Bool) {
        self.diskStorage = storage
        self.iCloudSync = iCloudSync
        setupCloudSync()
        
        diskNotification = NSNotificationCenter.defaultCenter()
            .addObserverForName(NSUserDefaultsDidChangeNotification,
                object: storage,
                queue: NSOperationQueue.mainQueue()) { _ in Signals.diskStorageChanged.fire(self) }
    }
    
    deinit {
        if let obj = iCloudNotification { NSNotificationCenter.defaultCenter().removeObserver(obj) }
        if let obj = diskNotification { NSNotificationCenter.defaultCenter().removeObserver(obj) }
    }
    
    // MARK: iCloud sync functions
    private func setupCloudSync() {
        if let obj = iCloudNotification { NSNotificationCenter.defaultCenter().removeObserver(obj) }
        
        if iCloudSync {
            iCloudNotification = NSNotificationCenter.defaultCenter()
                .addObserverForName(NSUbiquitousKeyValueStoreDidChangeExternallyNotification,
                    object: nil,
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: iCloudStorageChanged)
        }
        
        solveDiskCloudCollision()
    }
    private func solveDiskCloudCollision() {
        if !iCloudSync { return }
        iCloudStorage.synchronize() // Get most recent info
        
        let diskInfo = diskStorage.dictionaryRepresentation()
        let cloudInfo = iCloudStorage.dictionaryRepresentation
        
        var useCloud: Bool
        var mostRecentTimestamp: NSDate
        if iCloudTimestamp == nil {
            useCloud = false
            mostRecentTimestamp = diskTimestamp ?? NSDate()
        }
        else if diskTimestamp == nil {
            useCloud = true
            mostRecentTimestamp = iCloudTimestamp ?? NSDate()
        }
        else {
            useCloud = iCloudTimestamp! > diskTimestamp!
            mostRecentTimestamp = useCloud ? iCloudTimestamp! : diskTimestamp!
        }
        
        for (k, v) in useCloud ? cloudInfo : diskInfo {
            if useCloud { diskStorage.setObject(v, forKey: k as String) }
            else { iCloudStorage.setObject(v, forKey: k as String) }
        }
        
        diskStorage.setObject(mostRecentTimestamp, forKey: timestampKey)
        iCloudStorage.setObject(mostRecentTimestamp, forKey: timestampKey)
        
        iCloudStorage.synchronize() // Save changes
        Signals.cloudStorageUpdatedDiskStorage.fire(self)
    }
    private func iCloudStorageChanged(notification: NSNotification!) {
        let userInfo = notification.userInfo as [String:AnyObject]
        let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as Int
        let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as [String]
        
        switch reason {
        case NSUbiquitousKeyValueStoreServerChange: fallthrough
        case NSUbiquitousKeyValueStoreInitialSyncChange: fallthrough
        case NSUbiquitousKeyValueStoreAccountChange: solveDiskCloudCollision()
        default: break
        }
    }
    
    // MARK: setObject helper functions
    private func setObjectOnDisk<T>(object: AnyObject?, forKey key: UDKey<T>) {
        diskStorage.setObject(object, forKey: key.name)
        if key.iCloudSync { diskStorage.setObject(NSDate(), forKey: timestampKey) }
    }
    
    private func setObjectOnCloud<T>(object: AnyObject?, forKey key: UDKey<T>) {
        if iCloudSync && key.iCloudSync {
            iCloudStorage.setObject(object, forKey: key.name)
            iCloudStorage.setObject(NSDate(), forKey: timestampKey)
            iCloudStorage.synchronize()
        }
    }
    
    // MARK: - _ObjectiveCBridgeable
    public func get <T: PropertyList>(key: UDKey<T>) -> T {
        if exists(key) { return diskStorage.objectForKey(key.name) as T }
        else { return key.defaultValue }
    }
    public func set <T: PropertyList>(key: UDKey<T>, _ value: T) {
        let v = value as T._ObjectiveCType
        setObjectOnDisk(v, forKey: key)
        setObjectOnCloud(v, forKey: key)
    }
    public func change <T: PropertyList>(key: UDKey<T>, block: (inout value: T)->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    // MARK: NSCoding
    public func get <T: NSCoding>(key: UDKey<T>) -> T {
        if exists(key) { return NSKeyedUnarchiver.unarchiveObjectWithData(diskStorage.objectForKey(key.name) as NSData) as T }
        else { return key.defaultValue }
    }
    public func set <T: NSCoding>(key: UDKey<T>, _ value: T) {
        let v = NSKeyedArchiver.archivedDataWithRootObject(value)
        setObjectOnDisk(v, forKey: key)
        setObjectOnCloud(v, forKey: key)
    }
    public func change <T: NSCoding>(key: UDKey<T>, block: (inout value: T)->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    // MARK: UserDefaultsConvertible
    public func get <T: UserDefaultsConvertible>(key: UDKey<T>) -> T {
        if exists(key) { return T(userDefaultsInfo: diskStorage.objectForKey(key.name) as T.UserDefaultsInfoType) }
        else { return key.defaultValue }
    }
    public func set <T: UserDefaultsConvertible>(key: UDKey<T>, _ value: T) {
        let v = value as T.UserDefaultsInfoType._ObjectiveCType
        setObjectOnDisk(v, forKey: key)
        setObjectOnCloud(v, forKey: key)
    }
    public func change <T: UserDefaultsConvertible>(key: UDKey<T>, block: (inout value: T)->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    public func get <T: UserDefaultsConvertible>(key: UDKey<[T]>) -> [T] {
        if exists(key) { return (diskStorage.objectForKey(key.name) as [T.UserDefaultsInfoType]).map { T(userDefaultsInfo: $0) } }
        else { return key.defaultValue }
    }
    public func set <T: UserDefaultsConvertible>(key: UDKey<[T]>, _ value: [T]) {
        let v = value.map { $0.userDefaultsInfo }
        setObjectOnDisk(v, forKey: key)
        setObjectOnCloud(v, forKey: key)
    }
    public func change <T: UserDefaultsConvertible>(key: UDKey<[T]>, block: (inout value: [T])->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    public func get <T: UserDefaultsConvertible>(key: UDKey<[String:T]>) -> [String:T] {
        if exists(key) { return (diskStorage.objectForKey(key.name) as [String:T.UserDefaultsInfoType]).map { ($0, T(userDefaultsInfo: $1)) } }
        else { return key.defaultValue }
    }
    public func set <T: UserDefaultsConvertible>(key: UDKey<[String:T]>, _ value: [String:T]) {
        let v = value.map { ($0, $1.userDefaultsInfo) }
        setObjectOnDisk(v, forKey: key)
        setObjectOnCloud(v, forKey: key)
    }
    public func change <T: UserDefaultsConvertible>(key: UDKey<[String:T]>, block: (inout value: [String:T])->()) {
        var v = get(key)
        block(value: &v)
        set(key, v)
    }
    
    // MARK: - Other functions
    public func exists <T>(key: UDKey<T>) -> Bool {
        return diskStorage.objectForKey(key.name) != nil
    }
    public func remove <T>(key: UDKey<T>) {
        diskStorage.removeObjectForKey(key.name)
        if key.iCloudSync { diskStorage.setObject(NSDate(), forKey: timestampKey) }
        
        if iCloudSync && key.iCloudSync {
            iCloudStorage.removeObjectForKey(key.name)
            iCloudStorage.setObject(NSDate(), forKey: timestampKey)
            iCloudStorage.synchronize()
        }
    }
    
    // MARK: Timestamps
    public var iCloudTimestamp: NSDate? { return iCloudStorage.objectForKey(timestampKey) as? NSDate }
    public var diskTimestamp: NSDate? { return diskStorage.objectForKey(timestampKey) as? NSDate }
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
