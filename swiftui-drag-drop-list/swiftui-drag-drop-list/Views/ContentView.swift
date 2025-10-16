//
//  ContentView.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 16/10/25.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State private var items = FileItem.mockItems
    @State private var selectedVariant = 0

    private let variants = [
        "Delete only",
        "Drag on separator only",
        "Drag on separator + other item",
        "Delete + Drag on separator",
        "Delete + Drag on separator + other item"
    ]
    
    var body: some View {
        VStack {
            Picker("Select variant", selection: $selectedVariant) {
                ForEach(0..<variants.count, id: \.self) { index in
                    Text(variants[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Spacer()
            
            Group {
                switch selectedVariant {
                case 0: // Delete only
                    DraggableListView(
                        items: items,
                        rowView: { FileItemRow(fileItem: $0) },
                        onDelete: { index in
                            print("Delete at \(index)")
                        }
                    )
                case 1: // Drag on separator only
                    DraggableListView(
                        items: items,
                        rowView: { FileItemRow(fileItem: $0) },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above) and \(below)")
                        }
                    )
                case 2: // Drag on separator + other item
                    DraggableListView(
                        items: items,
                        rowView: { FileItemRow(fileItem: $0) },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above) and \(below)")
                        },
                        onItemDroppedOnOtherItem: { dragged, target in
                            print("Dropped \(dragged.name) on \(target.name)")
                        }
                    )
                case 3: // Delete + Drag on separator
                    DraggableListView(
                        items: items,
                        rowView: { FileItemRow(fileItem: $0) },
                        onDelete: { index in
                            print("Delete at \(index)")
                        },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above) and \(below)")
                        }
                    )
                case 4: // Delete + Drag on separator + other item
                    DraggableListView(
                        items: items,
                        rowView: { FileItemRow(fileItem: $0) },
                        onDelete: { index in
                            print("Delete at \(index)")
                        },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above) and \(below)")
                        },
                        onItemDroppedOnOtherItem: { dragged, target in
                            print("Dropped \(dragged.name) on \(target.name)")
                        }
                    )
                default:
                    EmptyView()
                }
            }
            .animation(.default, value: selectedVariant)
            .padding()
            
            Spacer()
        }
    }
}
