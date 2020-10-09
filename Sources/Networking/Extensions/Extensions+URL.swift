//
//  File.swift
//  
//
//  Created by 16997598 on 09.10.2020.
//

import Foundation

extension URL {
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
