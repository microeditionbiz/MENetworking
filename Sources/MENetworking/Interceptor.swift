//
//  Interceptor.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 19/10/2022.
//

import Foundation

public struct Interceptor {
    public let before: ((URLRequest) -> URLRequest)?
    public let after: ((URLRequest, Result<(URLResponse, Data), Error>) -> Void)?

    public init(
        before: ((URLRequest) -> URLRequest)? = nil,
        after: ((URLRequest, Result<(URLResponse, Data), Error>) -> Void)? = nil) {
        self.before = before
        self.after = after
    }
}
