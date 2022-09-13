//
//  File.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 26/05/2022.
//

import Foundation
import MECore

extension URLSessionDataTask: Cancellable { }

public struct APIEndpoint<ResultType: Decodable> {
    public let path: String
    public let method: HTTPMethod
    public let queryParameters: [String: CustomStringConvertible]?

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
    }

    public func createURLRequest(baseURL: URL) -> URLRequest {
        let url = URLBuilder
            .init(with: baseURL)
            .with(path: path)
            .with(queryParams: queryParameters)
            .build()

        return URLRequestBuilder
            .init(with: url)
            .with(httpMethod: method)
            .with(httpBody: method.bodyData)
            .build()
    }
}
