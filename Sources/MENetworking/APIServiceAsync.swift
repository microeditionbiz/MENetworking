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

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            interceptors?.forEach { interceptor  in
                interceptor.after?(urlRequest, .success((urlResponse, data)))
            }

            let response = try endpoint.decode(data)
            return response
        } catch {
            interceptors?.forEach { interceptor  in
                interceptor.after?(urlRequest, .failure(error))
            }

            throw error
        }
    }

}
