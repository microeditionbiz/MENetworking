//
//  APIRequestMapper.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 22/01/2023.
//

import Foundation
import MENetworking

public enum APIRequestMapperError: Error {
    case routeNotFound
}

public typealias APIRequestMapper = (URLRequest) throws -> APIResponseMock
public typealias APIRequestMapperRoute = (httpMethod: String, urlPattern: String, response: APIResponseMock)

public final class APIRequestMapperBuilder {
    private var routes = [APIRequestMapperRoute]()

    public func append(httpMethod: HTTPMethod, urlPattern: String, response: APIResponseMock) -> Self {
        routes.append((httpMethod: httpMethod.name, urlPattern: urlPattern, response: response))
        return self
    }

    public func build() -> APIRequestMapper {
        return { [routes] request in
            let route = routes.first {
                guard
                    request.httpMethod == $0.httpMethod,
                    let absoluteURL = request.url?.absoluteString,
                    absoluteURL.matches(pattern: $0.urlPattern) else {
                    return false
                }

                return true
            }

            guard let route = route else {
                throw APIRequestMapperError.routeNotFound
            }

            return route.response
        }
    }
}
