//
//  WebRepository.swift
//  Networking
//
//  Created by Mikhail Seregin on 11.03.2020.
//  Copyright © 2020 Mikhail Seregin. All rights reserved.
//

import Foundation
import Combine

public protocol WebRepository {
    var session: URLSession { get }
    var baseURL: String { get }
    var queue: DispatchQueue { get }
    
    @available(OSX 10.15, *)
    @available(iOS 13.0, *)
    func call<Value>(endpoint: APICall, httpCodes: HTTPCodes, decoder: JSONDecoder) -> AnyPublisher<Value, Error>
        where Value: Decodable
}

@available(OSX 10.15, *)
@available(iOS 13, *)
extension WebRepository {
    public func call<Value>(endpoint: APICall, httpCodes: HTTPCodes = .success, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Value, Error>
        where Value: Decodable {
        do {
            let request = try endpoint.urlRequest(baseURL: baseURL)
            print(request)
            return session
                .dataTaskPublisher(for: request)
                .subscribe(on: queue)
                .print()
                .requestJSON(httpCodes: httpCodes, decoder: decoder)
                
        } catch let error {
            return Fail<Value, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
}

@available(OSX 10.15, *)
@available(iOS 13, *)
private extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func requestJSON<Value>(httpCodes: HTTPCodes, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Value, Error> where Value: Decodable {
        return tryMap {
            assert(!Thread.isMainThread)
            guard let code = ($0.1 as? HTTPURLResponse)?.statusCode else {
                throw APIError.unexpectedResponse
            }
            guard httpCodes.contains(code) else {
                guard let description = ($0.1 as? HTTPURLResponse)?.description else {
                    throw APIError.httpCode(code)
                }
                throw APIError.custom(description)
            }
            
            if $0.0.count == 0 {
                let empty = Empty()
                let data = try JSONEncoder().encode(empty)
                return data
            }
            NSLog(String(data: $0.0, encoding: .utf8) ?? "Нет Ошибки?")
            return $0.0
        }
        .decode(type: Value.self, decoder: decoder)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

public struct Empty: Codable {}
