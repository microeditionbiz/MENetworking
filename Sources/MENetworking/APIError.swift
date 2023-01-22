//
//  APIError.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 22/01/2023.
//

import Foundation

public protocol APIErrorProtocol {
    var message: String? { get }
    var code: String? { get }
}

public enum APIError: Error {
    case apiError(code: String, message: String?)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .apiError(statusCode, message):
            if let message = message {
                return "\(message) (\(statusCode))."
            } else {
                return statusCode
            }
        }
    }
}
