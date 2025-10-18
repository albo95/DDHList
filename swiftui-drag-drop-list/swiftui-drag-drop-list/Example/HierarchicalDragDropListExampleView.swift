//
//  ContentView.swift
//  HierarchicalDragDropListExampleView
//
//  Created by Alberto Bruno on 16/10/25.
//

import Foundation
import SwiftUI

struct HierarchicalDragDropListExampleView: View {
    @State private var items = HierarchicalFileItemExample.mockItems
    @State private var selectedVariant = 0

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
                    DragAndDropHierarchicalListView(
                        items: items,
                        rowView: { HierarchicalFileItemRowExample(hierarchicalFileItem: $0) },
                        onDelete: { item in
                            print("Delete \(item.name)")
                        }
                    )
                case 1: // Drag on separator only
                    DragAndDropHierarchicalListView(
                        items: items,
                        rowView: { HierarchicalFileItemRowExample(hierarchicalFileItem: $0) },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above.name) and \(below.name)")
                        }
                    )
                case 2: // Drag on separator + other item
                    DragAndDropHierarchicalListView(
                        items: items,
                        rowView: { HierarchicalFileItemRowExample(hierarchicalFileItem: $0) },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above.name) and \(below.name)")
                        },
                        onItemDroppedOnOtherItem: { dragged, target in
                            print("Dropped \(dragged.name) on \(target.name)")
                        }
                    )
                case 3: // Delete + Drag on separator
                    DragAndDropHierarchicalListView(
                        items: items,
                        rowView: { HierarchicalFileItemRowExample(hierarchicalFileItem: $0) },
                        onDelete: { item in
                            print("Delete \(item.name)")
                        },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above.name) and \(below.name)")
                        }
                    )
                case 4: // Delete + Drag on separator + other item
                    DragAndDropHierarchicalListView(
                        items: items,
                        rowView: { HierarchicalFileItemRowExample(hierarchicalFileItem: $0) },
                        onDelete: { item in
                            print("Delete \(item.name)")
                        },
                        onItemDroppedOnSeparator: { dragged, above, below in
                            print("Dropped \(dragged.name) between \(above.name) and \(below.name)")
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
