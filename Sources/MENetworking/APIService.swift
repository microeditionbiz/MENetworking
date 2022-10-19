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
    @discardableResult
    func execute<ResultType>(
        endpoint: APIEndpoint<ResultType>,
        completion: @escaping (Result<ResultType, Error>) -> Void
    ) -> Cancellable
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
    public func execute<ResultType>(
        endpoint: APIEndpoint<ResultType>,
        completion: @escaping (Result<ResultType, Error>) -> Void
    ) -> Cancellable {

        let urlRequest = endpoint.createURLRequest(baseURL: baseURL, interceptors: interceptors)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let data = data {
                    do {
                        let response = try endpoint.decode(data)
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
