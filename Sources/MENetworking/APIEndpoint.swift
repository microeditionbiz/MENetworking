//
//  APIEndpoint.swift
//  MENetworking
//
//  Created by Pablo Ezequiel Romero Giovannoni on 26/05/2022.
//

import Foundation

public struct APIEndpoint<ResultType, ErrorType> {
    private let path: String
    private let method: HTTPMethod
    private let queryParameters: [String: CustomStringConvertible]?
    private let httpHeaders: [String: CustomStringConvertible]?
    let decodeResult: (Data) throws -> ResultType
    let decodeError: (Data) throws -> ErrorType

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        httpHeaders: [String: CustomStringConvertible]? = nil,
        decodeResult: @escaping (Data) throws -> ResultType,
        decodeError: @escaping (Data) throws -> ErrorType
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.httpHeaders = httpHeaders
        self.decodeResult = decodeResult
        self.decodeError = decodeError
    }

    public func createURLRequest(baseURL: URL, interceptors: [Interceptor.Before]?) -> URLRequest {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            fatalError("Error initalizing URLBuilder")
        }

        urlComponents.path = path

        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            let queryItems: [URLQueryItem] = queryParameters.map {
                .init(name: $0.key, value: $0.value.description)
            }

            if urlComponents.queryItems == nil {
                urlComponents.queryItems = queryItems
            } else {
                urlComponents.queryItems?.append(contentsOf: queryItems)
            }
        }

        guard let url = urlComponents.url else {
            fatalError("Error buidling URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.name
        urlRequest.httpBody = method.body

        httpHeaders?.forEach {
            urlRequest.setValue($0.value.description, forHTTPHeaderField: $0.key)
        }

        return interceptors?.reduce(urlRequest) { partialResult, interceptor in
            interceptor.apply(partialResult)
        } ?? urlRequest
    }
}

public extension APIEndpoint where ResultType: Decodable, ErrorType: Decodable {
    init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        httpHeaders: [String: CustomStringConvertible]? = nil,
        decoder: JSONDecoder
    ) {
        self.init(
            path: path,
            method: method,
            queryParameters: queryParameters,
            httpHeaders: httpHeaders,
            decodeResult: { try decoder.decode(ResultType.self, from: $0) },
            decodeError: { try decoder.decode(ErrorType.self, from: $0) }
        )
    }
}

public extension APIEndpoint where ResultType == Void, ErrorType == Void  {
    init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        httpHeaders: [String: CustomStringConvertible]? = nil
    ) {
        self.init(
            path: path,
            method: method,
            queryParameters: queryParameters,
            decodeResult: { _ in () },
            decodeError: { _ in () }
        )
    }
}
