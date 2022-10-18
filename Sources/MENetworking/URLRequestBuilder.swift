//
//  URLRequestBuilder.swift
//  MENetworking
//
//  Created by Pablo Ezequiel Romero Giovannoni on 25/05/2022.
//

import Foundation

public final class URLRequestBuilder {
    private var urlRequest: URLRequest

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

    public func build() -> URLRequest {
        return urlRequest
    }

}
