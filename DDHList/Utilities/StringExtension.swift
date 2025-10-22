//
//  StringExtension.swift
//  DDHList
//
//  Created by Alberto Bruno on 22/10/25.
//

import Foundation

extension String.StringInterpolation {
    mutating func appendInterpolation<T>(_ value: T?) {
        if let value {
            appendLiteral("\(value)")
        } else {
            appendLiteral("nil")
        }
    }
}
