//
//  ItemExample.swift
//  DDList
//
//  Created by Alberto Bruno on 21/10/25.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

@available(iOS 16.0, *)
struct ItemExample: Transferable, Identifiable, Equatable, Hashable, Codable, DDHItem {
    let name: String
    var id: String { name }
    
    var children: [ItemExample] = []
        
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

@available(iOS 16.0, *)
extension ItemExample {
    @MainActor
    static let mockItem: ItemExample = ItemExample(name: "Mock")
    
    @MainActor
    static let mockItems: [ItemExample] = [
        ItemExample(
            name: "Documents",
            children: [
                ItemExample(name: "Resume.pdf"),
                ItemExample(name: "CoverLetter.docx"),
                ItemExample(
                    name: "Projects",
                    children: [
                        ItemExample(name: "ProjectA"),
                        ItemExample(name: "ProjectB"),
                        ItemExample(
                            name: "OldProjects",
                            children: [
                                ItemExample(name: "ProjectX"),
                                ItemExample(name: "ProjectY")
                            ]
                        )
                    ]
                )
            ]
        ),
        ItemExample(
            name: "Pictures",
            children: [
                ItemExample(name: "Vacation"),
                ItemExample(name: "Family"),
                ItemExample(
                    name: "Work",
                    children: [
                        ItemExample(name: "Conference"),
                        ItemExample(name: "TeamBuilding")
                    ]
                )
            ]
        ),
        ItemExample(
            name: "Music",
            children: [
                ItemExample(name: "Rock"),
                ItemExample(name: "Jazz"),
                ItemExample(name: "Classical")
            ]
        ),
        ItemExample(name: "Downloads"),
        ItemExample(name: "Desktop")
    ]
    
    @MainActor
    static let repeatedMockItems: [ItemExample] = {
        (0..<10).flatMap { repetitionIndex in
            mockItems.map { item in
                func assignUniqueIDs(_ item: ItemExample, prefix: String) -> ItemExample {
                    var copy = item
                    copy.children = copy.children.map { assignUniqueIDs($0, prefix: prefix) }
                    return ItemExample(name: "\(prefix)-\(copy.name)", children: copy.children)
                }
                return assignUniqueIDs(item, prefix: "\(repetitionIndex)")
            }
        }
    }()
}
