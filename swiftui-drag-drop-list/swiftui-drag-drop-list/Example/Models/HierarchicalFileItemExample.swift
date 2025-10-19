//
//  HierarchicalFileItemExample.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 17/10/25.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct HierarchicalFileItemExample: HierarchicalItemType, Hashable, Codable {
    let name: String
    var id: String { name }
    
    var childrens: [HierarchicalFileItemExample] = []
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

extension HierarchicalFileItemExample {
    static let mockItem: HierarchicalFileItemExample = HierarchicalFileItemExample(name: "Mock")

    static let mockItems: [HierarchicalFileItemExample] = [
        HierarchicalFileItemExample(
            name: "Documents",
            childrens: [
                HierarchicalFileItemExample(name: "Resume.pdf"),
                HierarchicalFileItemExample(name: "CoverLetter.docx"),
                HierarchicalFileItemExample(
                    name: "Projects",
                    childrens: [
                        HierarchicalFileItemExample(name: "ProjectA"),
                        HierarchicalFileItemExample(name: "ProjectB"),
                        HierarchicalFileItemExample(
                            name: "OldProjects",
                            childrens: [
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
            childrens: [
                HierarchicalFileItemExample(name: "Vacation"),
                HierarchicalFileItemExample(name: "Family"),
                HierarchicalFileItemExample(
                    name: "Work",
                    childrens: [
                        HierarchicalFileItemExample(name: "Conference"),
                        HierarchicalFileItemExample(name: "TeamBuilding")
                    ]
                )
            ]
        ),
        HierarchicalFileItemExample(
            name: "Music",
            childrens: [
                HierarchicalFileItemExample(name: "Rock"),
                HierarchicalFileItemExample(name: "Jazz"),
                HierarchicalFileItemExample(name: "Classical")
            ]
        ),
        HierarchicalFileItemExample(name: "Downloads"),
        HierarchicalFileItemExample(name: "Desktop")
    ]
}
