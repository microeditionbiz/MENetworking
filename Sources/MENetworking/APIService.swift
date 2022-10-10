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

public struct Interceptor {
    public let before: ((URLRequest) -> URLRequest)?
    public let after: ((URLRequest, URLResponse, Data, Error) -> Void)?

    public init(
        before: ((URLRequest) -> URLRequest)? = nil,
        after: ((URLRequest, URLResponse, Data, Error) -> Void)? = nil) {
        self.before = before
        self.after = after
    }
}

public protocol APIServiceProtocol {
    @discardableResult
    func execute<ResultType: Decodable>(
        endpoint: APIEndpoint<ResultType>,
        decoder: JSONDecoder,
        completion: @escaping (Result<ResultType, Error>) -> Void
    ) -> Cancellable
}

public protocol APIServiceAsyncProtocol {
    func execute<ResultType: Decodable>(
        endpoint: APIEndpoint<ResultType>,
        decoder: JSONDecoder
    ) async throws -> ResultType
}

public final class APIService {
    public let baseURL: URL
    public let interceptors: [Interceptor]?

    public init(baseURL: URL, interceptors: [Interceptor]? = nil) {
        self.baseURL = baseURL
        self.interceptors = interceptors
    }

}

extension APIService: APIServiceProtocol {

    @discardableResult
    public func execute<ResultType: Decodable>(
        endpoint: APIEndpoint<ResultType>,
        decoder: JSONDecoder = .init(),
        completion: @escaping (Result<ResultType, Error>) -> Void
    ) -> Cancellable {

        let urlRequest = interceptors?.reduce(endpoint.createURLRequest(baseURL: baseURL)) { partialResult, interceptor in
            interceptor.before.map { $0(partialResult) } ?? partialResult
        } ?? endpoint.createURLRequest(baseURL: baseURL)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let data = data {
                    do {
                        let response = try decoder.decode(ResultType.self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(APIServiceError.emptyData))
                }
            }
        }
        
        dataTask.resume()

        return dataTask
    }
    
}

extension APIService: APIServiceAsyncProtocol {

    public func execute<ResultType: Decodable>(
        endpoint: APIEndpoint<ResultType>,
        decoder: JSONDecoder
    ) async throws -> ResultType {

        let urlRequest = interceptors?.reduce(endpoint.createURLRequest(baseURL: baseURL)) { partialResult, interceptor in
            interceptor.before.map { $0(partialResult) } ?? partialResult
        } ?? endpoint.createURLRequest(baseURL: baseURL)

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let response = try decoder.decode(ResultType.self, from: data)

        return response
    }
    
}
