//
//  URLRequestBuilder.swift
//  MENetworking
//
//  Created by Pablo Ezequiel Romero Giovannoni on 25/05/2022.
//

import Foundation

public final class URLRequestBuilder {
    private var urlRequest: URLRequest
    private var beforeInterceptors: [(URLRequest) -> URLRequest]?

    public init(with url: URL) {
        urlRequest = .init(url: url)
    }

    public func with(httpMethod: HTTPMethod) -> Self {
        urlRequest.httpMethod = httpMethod.name
        return self
    }

    public func with(httpBody: Data?) -> Self {
        urlRequest.httpBody = httpBody
        return self
    }

    public func with<ObjectType: Encodable>(httpBodyObject value: ObjectType, encoder: JSONEncoder = .init()) -> Self {
        do {
            let data = try encoder.encode(value)
            urlRequest.httpBody = data
            return self
        } catch {
            fatalError("Error encoding object \(error)")
        }
    }

    public func with(interceptors: [Interceptor]?) -> Self {
        beforeInterceptors = interceptors?.compactMap(\.before)
        return self
    }

    public func build() -> URLRequest {
        beforeInterceptors?.reduce(urlRequest) { partialResult, interceptor in
            interceptor(partialResult)
        } ?? urlRequest
    }

}
