//
//  APIServicePublisher.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 19/10/2022.
//

import Foundation
import Combine

public protocol APIServicePublisherProtocol {
    func execute<ResultType>(endpoint: APIEndpoint<ResultType>) -> AnyPublisher<ResultType, Error>
}

extension APIService: APIServicePublisherProtocol {

    public func execute<ResultType>(endpoint: APIEndpoint<ResultType>) -> AnyPublisher<ResultType, Error> {

        let urlRequest = endpoint.createURLRequest(baseURL: baseURL, interceptors: interceptors)

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result -> ResultType in
                try endpoint.decode(result.data)
            }
            .eraseToAnyPublisher()
    }

}
