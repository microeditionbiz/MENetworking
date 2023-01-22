//
//  APIService.swift
//  MENetworking
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

public enum APIServiceError: Error {
    case emptyData
}

public protocol APIServiceProtocol {
    func execute<ResultType, ErrorType: APIErrorProtocol>(endpoint: APIEndpoint<ResultType, ErrorType>) async throws -> ResultType
}

public typealias DataTask = (URLRequest) async throws -> (Data, URLResponse)

public final class APIService {
    private let baseURL: URL
    private let dataTask: DataTask
    private let beforeInterceptors: [Interceptor.Before]?
    private let afterInterceptors: [Interceptor.After]?

    public init(
        baseURL: URL,
        dataTask: @escaping DataTask = URLSession.shared.data(for:),
        beforeInterceptors: [Interceptor.Before]? = nil,
        afterInterceptors: [Interceptor.After]? = nil) {
            self.baseURL = baseURL
            self.dataTask = dataTask
            self.beforeInterceptors = beforeInterceptors
            self.afterInterceptors = afterInterceptors
    }
}

extension APIService: APIServiceProtocol {

    public func execute<ResultType, ErrorType: APIErrorProtocol>(endpoint: APIEndpoint<ResultType, ErrorType>) async throws -> ResultType {
        let urlRequest = endpoint.createURLRequest(baseURL: baseURL, interceptors: beforeInterceptors)

        do {
            let (data, response) = try await dataTask(urlRequest)

            if let statusCode = (response as? HTTPURLResponse)?.statusCode, !(200..<300 ~= statusCode) {
                let decodedError = try? endpoint.decodeError(data)
                let error: APIError = decodedError.map {
                    .apiError(code: $0.code ?? "\(statusCode)", message: $0.message)
                } ?? .apiError(code: "\(statusCode)", message: nil)

                throw error
            } else {
                afterInterceptors?
                    .map(\.apply)
                    .forEach { $0(urlRequest, .success((response, data))) }

                return try endpoint.decodeResult(data)
            }
        } catch {
            afterInterceptors?
                .map(\.apply)
                .forEach { $0(urlRequest, .failure(error)) }

            throw error
        }
    }
    
}
