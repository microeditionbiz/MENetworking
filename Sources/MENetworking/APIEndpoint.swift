//
//  APIEndpoint.swift
//  MENetworking
//
//  Created by Pablo Ezequiel Romero Giovannoni on 26/05/2022.
//

import Foundation

extension URLSessionDataTask: Cancellable { }

public struct APIEndpoint<ResultType> {
    public let path: String
    public let method: HTTPMethod
    public let queryParameters: [String: CustomStringConvertible]?
    public let decode: (Data) throws -> ResultType

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        decode: @escaping (Data) throws -> ResultType
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.decode = decode
    }

    public func createURLRequest(baseURL: URL, interceptors: [Interceptor]?) -> URLRequest {
        let url = URLBuilder
            .init(with: baseURL)
            .with(path: path)
            .with(queryParams: queryParameters)
            .build()

        return URLRequestBuilder
            .init(with: url)
            .with(httpMethod: method)
            .with(httpBody: method.body)
            .with(interceptors: interceptors)
            .build()
    }
}

public extension APIEndpoint where ResultType: Decodable {
    init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        decoder: JSONDecoder = .init()
    ) {
        self.init(
            path: path,
            method: method,
            queryParameters: queryParameters,
            decode: { try decoder.decode(ResultType.self, from: $0) } )
    }
}

public extension APIEndpoint where ResultType == Void {
    init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        decoder: JSONDecoder = .init()
    ) {
        self.init(
            path: path,
            method: method,
            queryParameters: queryParameters,
            decode: { _ in () } )
    }
}
