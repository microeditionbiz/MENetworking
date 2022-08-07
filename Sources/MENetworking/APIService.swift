//
//  APIService.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation
import MECore

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
        completion: @escaping (Result<ResultType, Error>)->Void
    ) -> Cancellable
}

public final class APIService: APIServiceProtocol {
    public let baseURL: URL
    public let interceptors: [Interceptor]?

    public init(baseURL: URL, interceptors: [Interceptor]? = nil) {
        self.baseURL = baseURL
        self.interceptors = interceptors
    }
    
    @discardableResult
    public func execute<ResultType: Decodable>(
        endpoint: APIEndpoint<ResultType>,
        decoder: JSONDecoder = .init(),
        completion: @escaping (Result<ResultType, Error>) -> Void
    ) -> Cancellable {

        let urlRequest = interceptors?.reduce(endpoint.createURLRequest(baseURL: baseURL)) { partialResult, interceptor in
            guard let before = interceptor.before else { return partialResult }
            return before(partialResult)
        } ?? endpoint.createURLRequest(baseURL: baseURL)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, URLResponse, error in
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
