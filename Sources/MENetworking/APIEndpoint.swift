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
    public let bodyData: Data?

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        bodyData: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.bodyData = bodyData
    }

    public func createURLRequest(baseURL: URL) -> URLRequest {
        let url = URLBuilder
            .init(with: baseURL)
            .withPath(path)
            .appendQueryParams(queryParameters)
            .build()

        return URLRequestBuilder
            .init(with: url)
            .withHTTPMethod(method)
            .withHTTPBody(bodyData)
            .build()
    }
}
