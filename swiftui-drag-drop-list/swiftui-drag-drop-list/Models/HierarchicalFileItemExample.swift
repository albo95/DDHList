//
//  HierarchicalFileItemExample.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 17/10/25.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct HierarchicalFileItemExample: ItemHierarchicalType, Hashable, Codable {
    let name: String
    var id: String { name }
    
    var children: [HierarchicalFileItemExample] = []
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

extension HierarchicalFileItemExample {
    static let mockItem: HierarchicalFileItemExample = HierarchicalFileItemExample(name: "Mock")

    static let mockItems: [HierarchicalFileItemExample] = [
        HierarchicalFileItemExample(
            name: "Documents",
            children: [
                HierarchicalFileItemExample(name: "Resume.pdf"),
                HierarchicalFileItemExample(name: "CoverLetter.docx"),
                HierarchicalFileItemExample(
                    name: "Projects",
                    children: [
                        HierarchicalFileItemExample(name: "ProjectA"),
                        HierarchicalFileItemExample(name: "ProjectB"),
                        HierarchicalFileItemExample(
                            name: "OldProjects",
                            children: [
                                HierarchicalFileItemExample(name: "ProjectX"),
                                HierarchicalFileItemExample(name: "ProjectY")
                            ]
                        )
                    ]
                )
            ]
        ),
        HierarchicalFileItemExample(
            name: "Pictures",
            children: [
                HierarchicalFileItemExample(name: "Vacation"),
                HierarchicalFileItemExample(name: "Family"),
                HierarchicalFileItemExample(
                    name: "Work",
                    children: [
                        HierarchicalFileItemExample(name: "Conference"),
                        HierarchicalFileItemExample(name: "TeamBuilding")
                    ]
                )
            ]
        ),
        HierarchicalFileItemExample(
            name: "Music",
            children: [
                HierarchicalFileItemExample(name: "Rock"),
                HierarchicalFileItemExample(name: "Jazz"),
                HierarchicalFileItemExample(name: "Classical")
            ]
        ),
        HierarchicalFileItemExample(name: "Downloads"),
        HierarchicalFileItemExample(name: "Desktop")
    ]
}
