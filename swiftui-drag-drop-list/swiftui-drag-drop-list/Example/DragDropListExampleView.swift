//
//  DragDropListExampleView.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 17/10/25.
//

import Foundation
import SwiftUI

struct DragDropListExampleView: View {
    @State private var items = FileItemExample.mockItems
    @State private var selectedVariant = 4

    private let variants = [
        "D",
        "DS",
        "DS-DI",
        "D-DS",
        "D-DS-DI"
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
                    DragAndDropListView(
                        items: items,
                        rowView: { FileItemRowExampleView(fileItem: $0) },
                        onDelete: { index in
                            print("Delete at \(index)")
                        },
                        deleteView: { AnyView(DeleteExampleView()) }
                    )
                case 1: // Drag on separator only
                    DragAndDropListView(
                        items: items,
                        rowView: { FileItemRowExampleView(fileItem: $0) },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above) and \(below)")
                        },
                        separatorView: { SeparatorViewExample() }
                    )
                case 2: // Drag on separator + other item
                    DragAndDropListView(
                        items: items,
                        rowView: { FileItemRowExampleView(fileItem: $0) },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above) and \(below)")
                        },
                        onItemDroppedOnOtherItem: { dragged, target in
                            print("Dropped \(dragged.name) on \(target.name)")
                        }
                    )
                case 3: // Delete + Drag on separator
                    DragAndDropListView(
                        items: items,
                        rowView: { FileItemRowExampleView(fileItem: $0) },
                        onDelete: { index in
                            print("Delete at \(index)")
                        },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above) and \(below)")
                        }
                    )
                case 4: // Delete + Drag on separator + other item
                    DragAndDropListView(
                        items: items,
                        rowView: { FileItemRowExampleView(fileItem: $0)
                            .background(.white)},
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
