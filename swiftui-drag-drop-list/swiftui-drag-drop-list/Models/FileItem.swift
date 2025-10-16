//
//  FileItem.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 15/10/25.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct FileItem: Identifiable, Hashable, Codable, Transferable {
    let name: String
    var children: [FileItem]?
    
    var id: String { name }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

extension FileItem {
    static let mockItem: FileItem = FileItem(name: "Mock")
    
    static let mockItems: [FileItem] = [
        FileItem(
            name: "Documents",
            children: [
                FileItem(name: "Resume.pdf"),
                FileItem(name: "Invoices", children: [
                    FileItem(name: "Invoice_January.pdf"),
                    FileItem(name: "Invoice_February.pdf"),
                    FileItem(name: "Invoice_March.pdf")
                ]),
                FileItem(name: "Notes.txt"),
                FileItem(name: "Meeting_Minutes.docx"),
                FileItem(name: "ProjectProposal.pdf")
            ]
        ),
        FileItem(
            name: "Pictures",
            children: [
                FileItem(name: "Vacation", children: [
                    FileItem(name: "Beach.png"),
                    FileItem(name: "Mountains.jpg"),
                    FileItem(name: "City.mov"),
                    FileItem(name: "Lake.jpeg")
                ]),
                FileItem(name: "Profile.jpg"),
                FileItem(name: "Event", children: [
                    FileItem(name: "Birthday.png"),
                    FileItem(name: "Wedding.mov")
                ])
            ]
        ),
        FileItem(
            name: "Music",
            children: [
                FileItem(name: "Album 1", children: [
                    FileItem(name: "Track1.mp3"),
                    FileItem(name: "Track2.mp3"),
                    FileItem(name: "Track3.mp3")
                ]),
                FileItem(name: "Album 2", children: [
                    FileItem(name: "SongA.mp3"),
                    FileItem(name: "SongB.mp3"),
                    FileItem(name: "SongC.mp3")
                ]),
                FileItem(name: "Classics", children: [
                    FileItem(name: "Beethoven.mp3"),
                    FileItem(name: "Mozart.mp3"),
                    FileItem(name: "Bach.mp3")
                ])
            ]
        ),
        FileItem(
            name: "Projects",
            children: [
                FileItem(name: "AppVoice2Text", children: [
                    FileItem(name: "README.md"),
                    FileItem(name: "Sources", children: [
                        FileItem(name: "ContentView.swift"),
                        FileItem(name: "TranscriptionManager.swift"),
                        FileItem(name: "VoiceService.swift")
                    ]),
                    FileItem(name: "Assets.xcassets"),
                    FileItem(name: "Documentation.pdf")
                ]),
                FileItem(name: "Parts", children: [
                    FileItem(name: "DrawingView.swift"),
                    FileItem(name: "CoordinateManager.swift"),
                    FileItem(name: "PaintEngine.swift")
                ]),
                FileItem(name: "WebApp", children: [
                    FileItem(name: "index.html"),
                    FileItem(name: "style.css"),
                    FileItem(name: "script.js"),
                    FileItem(name: "images", children: [
                        FileItem(name: "logo.png"),
                        FileItem(name: "banner.jpg")
                    ])
                ])
            ]
        ),
        FileItem(
            name: "Downloads",
            children: [
                FileItem(name: "Software", children: [
                    FileItem(name: "Xcode.dmg"),
                    FileItem(name: "VSCode.dmg")
                ]),
                FileItem(name: "Ebooks", children: [
                    FileItem(name: "SwiftUI_Guide.pdf"),
                    FileItem(name: "iOS_Development.pdf")
                ]),
                FileItem(name: "Movies", children: [
                    FileItem(name: "Inception.mkv"),
                    FileItem(name: "Matrix.mp4")
                ])
            ]
        ),
        FileItem(
            name: "Desktop",
            children: [
                FileItem(name: "Todo.txt"),
                FileItem(name: "Screenshots", children: [
                    FileItem(name: "Screen1.png"),
                    FileItem(name: "Screen2.png"),
                    FileItem(name: "Screen3.png")
                ]),
                FileItem(name: "Work", children: [
                    FileItem(name: "Presentation.key"),
                    FileItem(name: "Budget.xlsx")
                ])
            ]
        )
    ]
}
