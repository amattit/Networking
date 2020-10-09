//
//  File.swift
//  
//
//  Created by 16997598 on 09.10.2020.
//

import Foundation

public typealias HTTPCode = Int
public typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    static let success = 200 ..< 300
}
