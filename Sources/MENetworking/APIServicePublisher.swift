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

        let urlRequest = endpoint.createURLRequest(baseURL: baseURL, interceptors: beforeInterceptors)

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .handleEvents(
                receiveOutput: { [weak self] (data, urlResponse) in
                    self?.afterInterceptors?
                        .map(\.apply)
                        .forEach { $0(urlRequest, .success((urlResponse, data))) }
                }, receiveCompletion: { [weak self] completion in
                    guard case let .failure(error) = completion else { return }
                    self?.afterInterceptors?
                        .map(\.apply)
                        .forEach { $0(urlRequest, .failure(error)) }
                }
            )
            .tryMap { result -> ResultType in
                try endpoint.decode(result.data)
            }
            .eraseToAnyPublisher()
    }

}
