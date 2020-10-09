//
//  HTTPCodes.swift
//  Networking
//
//  Created by Mikhail Seregin on 11.03.2020.
//  Copyright © 2020 Mikhail Seregin. All rights reserved.
//

import Foundation

public typealias HTTPCode = Int
public typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    public static let success = 200 ..< 300
}
