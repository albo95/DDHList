//
//  DictionaryExtension.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 20/10/25.
//

import Foundation

extension Dictionary where Key == [Int], Value == CGFloat {
    func heights(forDepth depth: Int) -> [CGFloat] {
        let filteredHeights = self.filter { $0.key.count == depth }
                                  .map { $0.value }
        print("Heights for depth \(depth):", filteredHeights)
        return filteredHeights
    }
}

import SwiftUI

extension Dictionary where Key == [Int], Value == CGFloat {
    func totalHeightInSameLevel(for path: [Int]) -> CGFloat {
        guard !path.isEmpty else { return 0 }
        let count = path.count
        let lastIndex = path.last!
        
        var sum: CGFloat = 0
        
        for (key, value) in self {
            if key.count == count && key.dropLast() == path.dropLast() && key.last! <= lastIndex {
                sum += value
            }
        }
        
        return sum
    }
}

extension Dictionary where Key == [Int], Value == CGFloat {
    func totalOffset(for targetPath: [Int], expandedPaths: [[Int]]) -> CGFloat {
        var sum: CGFloat = 0
        var found = false

        func visit(itemsPath: [Int]) {
            guard !found else { return }

            let currentHeight = self[itemsPath] ?? 0
            sum += currentHeight
            sum += .separatorHeight

            if itemsPath == targetPath {
                found = true
                return
            }

            if expandedPaths.contains(itemsPath) {
                var childIndex = 0
                while true {
                    let childPath = itemsPath + [childIndex]
                    if self.keys.contains(childPath) {
                        visit(itemsPath: childPath)
                        childIndex += 1
                    } else {
                        break
                    }
                }
            }
        }

        var index = 0
        while !found {
            let path = [index]
            if self.keys.contains(path) {
                visit(itemsPath: path)
                index += 1
            } else {
                break
            }
        }

        return sum
    }
}
