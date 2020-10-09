//
//  APICall.swift
//  Networking
//
//  Created by Mikhail Seregin on 11.03.2020.
//  Copyright © 2020 Mikhail Seregin. All rights reserved.
//

import Foundation

public protocol APICall {
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var query: [String: String]? { get }
    func body() throws -> Data?
}

extension APICall {
    public func urlRequest(baseURL: String) throws -> URLRequest {
        
        var queryItems = [URLQueryItem]()
        if let query = query {
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        
        guard let url = URL(string: baseURL + path)?.appending(queryItems) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = try body()
        print(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")
        return request
    }
}
