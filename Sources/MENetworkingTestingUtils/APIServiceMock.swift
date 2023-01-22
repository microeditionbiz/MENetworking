//
//  APIServiceMock.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 22/01/2023.
//

import Foundation
import MENetworking

public extension APIService {
    static func mock(
        baseURL: URL = .init(string: "http://mock.com")!,
        requestMapper: @escaping APIRequestMapper,
        beforeInterceptors: [Interceptor.Before]? = nil,
        afterInterceptors: [Interceptor.After]? = nil
    ) -> Self {
        .init(
            baseURL: baseURL,
            dataTask: dataTaskBuilder(requestMapper: requestMapper),
            beforeInterceptors: beforeInterceptors,
            afterInterceptors: afterInterceptors
        )
    }
}

private func dataTaskBuilder(requestMapper: @escaping APIRequestMapper) -> DataTask {
    return { request in
        let response = try requestMapper(request)
        return (
            try response.contentData,
            HTTPURLResponse(url: request.url!, statusCode: response.statusCode, httpVersion: nil, headerFields: nil)!
        )
    }
}
