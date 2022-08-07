//
//  DiskCache.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 24/05/2022.
//

import Foundation

final public class DiskCache: Cache {
    public typealias Value = Data

    public func set(_ value: Value, for key: String) {

    }

    public func get(for key: String) -> Value? {
        return Data()
    }
}
