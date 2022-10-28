//
//  Interceptor.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 19/10/2022.
//

import Foundation

public enum Interceptor {
    public struct Before {
        public let apply: (URLRequest) -> URLRequest

        public init(apply: @escaping (URLRequest) -> URLRequest) {
            self.apply = apply
        }
    }

    public struct After {
        public let apply: (URLRequest, Result<(URLResponse, Data), Error>) -> Void

        public init(_ apply: @escaping (URLRequest, Result<(URLResponse, Data), Error>) -> Void) {
            self.apply = apply
        }
    }
}
