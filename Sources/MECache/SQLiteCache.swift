//
//  SQLiteCache.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 04/01/2022.
//

import Foundation

final public class SQLiteCache: Cache {
    public typealias Value = Data

    public func set(_ value: Value, for key: String) {

    }

    public func get(for key: String) -> Value? {
        return Data()
    }
}
