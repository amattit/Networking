//
//  File.swift
//  
//
//  Created by 16997598 on 09.10.2020.
//

import Foundation

public enum APIError: Swift.Error {
    
    case invalidURL
    case httpCode(HTTPCode)
    case unexpectedResponse
    case custom(String)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "Не удалось собрать Адрес"
        case .httpCode(let code):   return "Не ожидаемый HTTP код: \(code)"
        case .unexpectedResponse:   return "Не ожидаемый ответ от сервера"
        case .custom(let message):  return message
        }
    }
}
