//
//  MemoryCache.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 04/01/2022.
//

import Foundation

final public class MemoryCache<Value>: Cache {
    private class ObjectWrapper: NSObject {
        let _value: Value

        init(value: Value) {
            self._value = value
        }
    }

    private let cache = NSCache<NSString, ObjectWrapper>()

    public func set(_ value: Value, for key: String) {
        cache.setObject(.init(value: value), forKey: key as NSString)
    }

    public func get(for key: String) -> Value? {
        cache.object(forKey: key as NSString)?._value
    }
}
