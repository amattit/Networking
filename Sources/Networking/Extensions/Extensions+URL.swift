//
//  Extensions+URL.swift
//  Networking
//
//  Created by Mikhail Seregin on 11.03.2020.
//  Copyright © 2020 Mikhail Seregin. All rights reserved.
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
