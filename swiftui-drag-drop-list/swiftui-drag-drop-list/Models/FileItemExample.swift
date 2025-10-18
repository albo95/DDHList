//
//  FileItemExample.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 15/10/25.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct FileItemExample: Identifiable, Hashable, Codable, Transferable {
    var id: UUID = UUID()
    let name: String
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

extension FileItemExample {
    static let mockItem: FileItemExample = FileItemExample(name: "Mock")
    
    static let mockItems: [FileItemExample] = [
        FileItemExample(
            name: "Documents",
        ),
        FileItemExample(
            name: "Pictures",
        ),
        FileItemExample(
            name: "Music",
        ),
        FileItemExample(
            name: "Projects",
        ),
        FileItemExample(
            name: "Downloads",
        ),
        FileItemExample(
            name: "Desktop",
        )
    ]
}
