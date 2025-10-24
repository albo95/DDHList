//
//  IntArrayExtension.swift
//  DDList
//
//  Created by Alberto Bruno on 22/10/25.
//

import Foundation

@available(iOS 16.0, *)
extension Array where Element == Int {
    func withLast(_ newValue: Int) -> [Int] {
        guard !self.isEmpty else { return self }
        var copy = self
        copy[copy.count - 1] = newValue
        return copy
    }
    
    func incrementLast(by amount: Int = 1) -> [Int] {
        guard !self.isEmpty else { return self }
        var copy = self
        copy[copy.count - 1] += amount
        return copy
    }
    
    func decrementLast(by amount: Int = 1) -> [Int] {
        return incrementLast(by: -amount)
    }
    
    func addingLast(_ newValue: Int) -> [Int] {
        var copy = self
        copy.append(newValue)
        return copy
    }
}
