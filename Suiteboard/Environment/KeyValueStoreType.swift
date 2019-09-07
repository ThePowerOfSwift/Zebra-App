//
//  KeyValueStoreType.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation

public protocol KeyValueStoreType: class {
    func set(_ value: Bool, forKey defaultName: String)
    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
    
    func bool(forKey defaultName: String) -> Bool
    func dictionary(forKey defaultName: String) -> [String: Any]?
    func integer(forKey defaultName: String) -> Int
    func object(forKey defaultName: String) -> Any?
    func string(forKey defaultName: String) -> String?
    func synchronize() -> Bool
    
    func removeObject(forKey defaultName: String)
    
//    var tokenSaved: String { get set }
}

extension UserDefaults: KeyValueStoreType {
    
}

extension NSUbiquitousKeyValueStore: KeyValueStoreType {
    public func integer(forKey defaultName: String) -> Int {
        return Int(longLong(forKey: defaultName))
    }
    
    public func set(_ value: Int, forKey defaultName: String) {
        return set(Int64(value), forKey: defaultName)
    }
}
