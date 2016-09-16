//
//  UDWrapper.swift
//  DMS
//
//  Created by Freddy on 12/18/14.
//  Copyright (c) 2014 DMSCompany. All rights reserved.
//

import Foundation

class UDWrapper: NSObject {
    class func getObject(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
    class func getInt(key: String) -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(key)
    }
    
    class func getBool(key: String) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
    
    class func getFloat(key: String) -> Float {
        return NSUserDefaults.standardUserDefaults().floatForKey(key)
    }
    
    class func getString(key: String) -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(key)
    }
    
    class func getData(key: String) -> NSData? {
        return NSUserDefaults.standardUserDefaults().dataForKey(key)
    }
    
    class func getArray(key: String) -> NSArray? {
        return NSUserDefaults.standardUserDefaults().arrayForKey(key)
    }
    
    class func getDictionary(key: String) -> NSDictionary? {
        return NSUserDefaults.standardUserDefaults().dictionaryForKey(key)
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Get value with default value
    //-------------------------------------------------------------------------------------------
    
    class func getObject(key: String, defaultValue: AnyObject) -> AnyObject? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getObject(key)
    }
    
    class func getInt(key: String, defaultValue: Int) -> Int {
        if getObject(key) == nil {
            return defaultValue
        }
        return getInt(key)
    }
    
    class func getBool(key: String, defaultValue: Bool) -> Bool {
        if getObject(key) == nil {
            return defaultValue
        }
        return getBool(key)
    }
    
    class func getFloat(key: String, defaultValue: Float) -> Float {
        if getObject(key) == nil {
            return defaultValue
        }
        return getFloat(key)
    }
    
    class func getString(key: String, defaultValue: String) -> String? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getString(key)
    }
    
    class func getData(key: String, defaultValue: NSData) -> NSData? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getData(key)
    }
    
    class func getArray(key: String, defaultValue: NSArray) -> NSArray? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getArray(key)
    }
    
    class func getDictionary(key: String, defaultValue: NSDictionary) -> NSDictionary? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getDictionary(key)
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Set value
    //-------------------------------------------------------------------------------------------
    
    class func setObject(key: String, value: AnyObject?) {
        if value == nil {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        } else {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setInt(key: String, value: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setBool(key: String, value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setFloat(key: String, value: Float) {
        NSUserDefaults.standardUserDefaults().setFloat(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setString(key: String, value: NSString?) {
        if (value == nil) {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        } else {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setData(key: String, value: NSData) {
        setObject(key, value: value)
    }
    
    class func setArray(key: String, value: NSArray) {
        setObject(key, value: value)
    }
    
    
    class func setDictionary(key: String, value: NSDictionary) {
        setObject(key, value: value)
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Synchronize
    //-------------------------------------------------------------------------------------------
    
    class func Sync() {
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}