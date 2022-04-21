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
    func call<Value, E>(
        endpoint: APICall,
        httpCodes: HTTPCodes,
        decoder: JSONDecoder,
        errorType: E.Type
    ) -> AnyPublisher<Value, Error>
        where Value: Decodable, E: Decodable
    
    func callData<E>(
        endpoint: APICall,
        httpCodes: HTTPCodes,
        decoder: JSONDecoder,
        errorType: E.Type
    ) -> AnyPublisher<Data, Error>
        where E: Decodable
}

@available(OSX 10.15, *)
@available(iOS 13, *)
extension WebRepository {
    public func call<Value, E>(
        endpoint: APICall,
        httpCodes: HTTPCodes = .success,
        decoder: JSONDecoder = JSONDecoder(),
        errorType: E.Type
    ) -> AnyPublisher<Value, Error>
        where Value: Decodable, E: Decodable {
        do {
            let request = try endpoint.urlRequest(baseURL: baseURL)
            print(request)
            return session
                .dataTaskPublisher(for: request)
                .subscribe(on: queue)
                .requestJSON(httpCodes: httpCodes, decoder: decoder, errorType: E.self)
                .retry(2)
                .eraseToAnyPublisher()
                
        } catch let error {
            return Fail<Value, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    public func callData<E>(
        endpoint: APICall,
        httpCodes: HTTPCodes,
        decoder: JSONDecoder,
        errorType: E.Type
    ) -> AnyPublisher<Data, Error>
    where E: Decodable {
        do {
            let request = try endpoint.urlRequest(baseURL: baseURL)
            return session
                .dataTaskPublisher(for: request)
                .subscribe(on: queue)
                .tryMap { $0.data }
                .retry(2)
                .eraseToAnyPublisher()
        } catch let error {
            return Fail<Data, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
}

@available(OSX 10.15, *)
@available(iOS 13, *)
private extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func requestJSON<Value, E>(
        httpCodes: HTTPCodes,
        decoder: JSONDecoder = JSONDecoder(),
        errorType: E.Type
    ) -> AnyPublisher<Value, Error>
        where
        Value: Decodable,
        E: Decodable
    {
        return tryMap {
            assert(!Thread.isMainThread)
            guard let code = ($0.1 as? HTTPURLResponse)?.statusCode else {
                throw APIError.unexpectedResponse
            }
            guard httpCodes.contains(code) else {
                throw APIError.httpCode(code)
            }
            
            if $0.0.count == 0 {
                let empty = Empty()
                let data = try JSONEncoder().encode(empty)
                return data
            }
            
            if let pretty = $0.0.prettyPrintedJSONString {
                Swift.print(pretty)
            }
//            NSLog(String(data: $0.0, encoding: .utf8) ?? "Нет Ошибки?")
            return $0.0
        }
        .decode(type: Value.self, decoder: decoder)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

public struct Empty: Codable {
    public init() {}
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

fileprivate extension Publishers {
    struct RetryIf<P: Publisher>: Publisher {
        typealias Output = P.Output
        typealias Failure = P.Failure
        
        let publisher: P
        let times: Int
        let condition: (P.Failure) -> Bool
        
        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            guard times > 0 else { return publisher.receive(subscriber: subscriber) }
            
            publisher.catch { (error: P.Failure) -> AnyPublisher<Output, Failure> in
                if condition(error) {
                    return RetryIf(
                        publisher: publisher,
                        times: times - 1,
                        condition: condition
                    )
                    .eraseToAnyPublisher()
                } else {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .receive(subscriber: subscriber)
        }
    }
}
