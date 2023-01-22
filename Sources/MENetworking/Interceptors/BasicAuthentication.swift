//
//  BasicAuthentication.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 22/01/2023.
//

import Foundation

public typealias Credentials = (username: String, password: String)

private func base64LoginString(from credentials: Credentials?) -> String {
    guard let credentials = credentials else { return "" }
    let string = "\(credentials.username):\(credentials.password)"
        .data(using: .utf8)?
        .base64EncodedString(options: [])
    guard let string = string else {
        assertionFailure("Invalid credentials conversion")
        return ""
    }
    return string
}

public extension Interceptor.Before {
    static func basicAuthentication(credentialsProvider: @escaping () -> Credentials?) -> Self {
        .init { urlRequest in
            var mutableUrlRequest = urlRequest
            mutableUrlRequest.setValue(
                "Basic \(base64LoginString(from: credentialsProvider()))",
                forHTTPHeaderField: "Authorization")
            return mutableUrlRequest
        }
    }
}
