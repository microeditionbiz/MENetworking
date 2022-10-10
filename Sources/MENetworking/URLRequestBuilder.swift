//
//  URLRequestBuilder.swift
//  MENetworking
//
//  Created by Pablo Ezequiel Romero Giovannoni on 25/05/2022.
//

import Foundation

public enum HTTPMethod {
    case get
    case post(Data?)
    case put(Data?)
    case patch
    case delete
    case head

    public var stringRepresentation: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        case .head: return "HEAD"
        }
    }

    public var bodyData: Data? {
        switch self {
        case .get, .patch, .delete, .head: return nil
        case let .post(data): return data
        case let .put(data): return data
        }
    }
}

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

public final class URLRequestBuilder {
    private var urlRequest: URLRequest

    public init(with url: URL) {
        urlRequest = .init(url: url)
    }

    public func with(httpMethod: HTTPMethod) -> Self {
        urlRequest.httpMethod = httpMethod.stringRepresentation
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
