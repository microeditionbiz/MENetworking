//
//  APIServiceAsync.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 19/10/2022.
//

import Foundation

public protocol APIServiceAsyncProtocol {
    func execute<ResultType>(endpoint: APIEndpoint<ResultType>) async throws -> ResultType
}

extension APIService: APIServiceAsyncProtocol {

    public func execute<ResultType>(endpoint: APIEndpoint<ResultType>) async throws -> ResultType {

        let urlRequest = endpoint.createURLRequest(baseURL: baseURL, interceptors: interceptors)

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let response = try endpoint.decode(data)

        return response
    }

}
