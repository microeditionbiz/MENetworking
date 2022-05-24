//
//  APIService.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

// MARK: - API Error

public enum APIServiceError: Error {
    case emptyData
}

// MARK: - API Request

public final class APIRequest {
    let dataTask: URLSessionDataTask
    
    init(dataTask: URLSessionDataTask) {
        self.dataTask = dataTask
    }
    
    func cancel() {
        dataTask.cancel()
    }
}

// MARK: - API Endpoint

public enum APIHTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
    case PATCH = "PATCH"
}

public struct APIEndpoint<ResultType: Decodable> {
    public let path: String
    public let method: APIHTTPMethod
    public let queryParameters: [String: CustomStringConvertible]?
    public let bodyData: Data?
    public let resultType: ResultType.Type

    public init(
        path: String,
        method: APIHTTPMethod = .GET,
        queryParameters: [String: CustomStringConvertible]? = nil,
        bodyData: Data? = nil) {
            self.path = path
            self.method = method
            self.queryParameters = queryParameters
            self.bodyData = bodyData
            self.resultType = ResultType.self
    }

    public func createURLRequest(baseURL: URL) -> URLRequest {
        var urlComponents: URLComponents = .init(
            url: baseURL,
            resolvingAgainstBaseURL: true)!

        urlComponents.path = path

        urlComponents.queryItems = queryParameters.map { queryParameters in
            return queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value.description)
            }
        }

        var request = URLRequest.init(url: urlComponents.url!)
        request.httpMethod = method.rawValue

        if let bodyData = bodyData {
            request.httpBody = bodyData
        }

        return request
    }
}

// MARK: - API Service

public protocol APIServiceProtocol {
    @discardableResult
    func execute<ResultType: Decodable>(
        endpoint: APIEndpoint<ResultType>,
        decoder: JSONDecoder,
        completion: @escaping (Result<ResultType, Error>)->Void
    ) -> APIRequest
}

public final class APIService: APIServiceProtocol {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    @discardableResult
    public func execute<ResultType: Decodable>(
        endpoint: APIEndpoint<ResultType>,
        decoder: JSONDecoder = .init(),
        completion: @escaping (Result<ResultType, Error>)->Void
    ) -> APIRequest {
        let urlRequest = endpoint.createURLRequest(baseURL: baseURL)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, URLResponse, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let data = data {
                    do {
                        let response = try decoder.decode(endpoint.resultType, from: data)
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

        return .init(dataTask: dataTask)
    }
    
}
