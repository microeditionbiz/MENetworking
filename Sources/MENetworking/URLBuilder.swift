//
//  URLBuilder.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 18/10/2022.
//

import Foundation

public final class URLBuilder {
    private var urlComponents: URLComponents

    public init(with baseURL: URL) {
        guard let urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            fatalError("Error initalizing URLBuilder")
        }

        self.urlComponents = urlComponents
    }

    public func with(path: String) -> Self {
        urlComponents.path = path
        return self
    }

    public func with(queryParams params: [String: CustomStringConvertible]?) -> Self {
        guard let params = params, !params.isEmpty else { return self }

        let queryItems: [URLQueryItem] = params.map {
            URLQueryItem(name: $0.key, value: $0.value.description)
        }

        if urlComponents.queryItems == nil {
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems?.append(contentsOf: queryItems)
        }

        return self
    }

    public func build() -> URL {
        guard let url = urlComponents.url else {
            fatalError("Error buidling URL")
        }
        return url
    }

}
