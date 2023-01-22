//
//  APIResponseMock.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 22/01/2023.
//

import Foundation

public typealias File = (name: String, extension: String)

public struct APIResponseMock {
    let statusCode: Int
    let contentFile: File

    public init(statusCode: Int, contentFile: File) {
        self.statusCode = statusCode
        self.contentFile = contentFile
    }
}

public extension APIResponseMock {
    var contentData: Data {
        get throws {
            let contentFile = self.contentFile
            let url = try ResourceManager.url(for: contentFile.name, extension: contentFile.extension)
            return try Data(contentsOf: url)
        }
    }
}
