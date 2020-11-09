//
//  APIError.swift
//  Networking
//
//  Created by Mikhail Seregin on 11.03.2020.
//  Copyright © 2020 Mikhail Seregin. All rights reserved.
//

import Foundation

public enum APIError: Swift.Error {
    
    case invalidURL
    case httpCode(HTTPCode)
    case unexpectedResponse
    case custom(String)
    case decodable(Decodable)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:           return "Не удалось собрать Адрес"
        case .httpCode(let code):   return "Не ожидаемый HTTP код: \(code)"
        case .unexpectedResponse:   return "Не ожидаемый ответ от сервера"
        case .custom(let message):  return message
        case .decodable:               return "Не ожидаемый ответ"
        }
    }
    
    public var decodable: Decodable? {
        switch self {
        case .decodable(let decodable):
            return decodable
        default:
            return nil
        }
    }
}
