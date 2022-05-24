//
//  ComposableCache.swift
//
//
//  Created by Pablo Ezequiel Romero Giovannoni on 04/01/2022.
//

import Foundation
import Combine

public protocol Cache {
    associatedtype Value

    func set(_ value: Value, for key: String)
    func get(for key: String) -> Value?
//    func get(for key: String) -> AnyPublisher<Value?>
//    func get(for key: String) -> async Value?
}

public extension Cache {
    func compose<B: Cache>(other: B) -> ComposedCache<Value> where B.Value == Value {
        return ComposedCache<Value>(
            get: { key in
                guard let value = self.get(for: key) else {
                    return other.get(for: key)
                        .map { otherValue in
                            self.set(otherValue, for: key)
                            return otherValue
                        }
                }
                return value
            },
            set: { value, key in
                self.set(value, for: key)
                other.set(value, for: key)
            })
    }

    func mapValue<B: Cache>(
        other: B,
        _ f: @escaping (Value?) -> B.Value?,
        _ invf: @escaping (B.Value) -> Value) -> ComposedCache<B.Value> {
            return ComposedCache<B.Value>(
                get: { key in
                    f(self.get(for: key))
                },
                set: { value, key in
                    self.set(invf(value), for: key)
                })
        }
}

final public class ComposedCache<Value>: Cache {
    private let _get: (String) -> Value?
    private let _set: (Value, String) -> Void

    public init(
        get: @escaping (String) -> Value?,
        set: @escaping (Value, String) -> Void) {
        self._get = get
        self._set = set
    }

    public func set(_ value: Value, for key: String) {
        self._set(value, key)
    }

    public func get(for key: String) -> Value? {
        return self._get(key)
    }
}
