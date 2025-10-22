//
//  DDHListExample.swift
//  DDHList
//
//  Created by Alberto Bruno on 22/10/25.
//

import SwiftUI

struct DDHListExamplePicker: View {
    @State private var selectedView: Int = 0
    
    var body: some View {
        VStack {
            Picker("Select List Type", selection: $selectedView) {
                Text("D").tag(0)
                Text("D + DS").tag(1)
                Text("D + DSI").tag(2)
                Text("DI").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
                        
            // Mostra la view selezionata
            Group {
                switch selectedView {
                case 0:
                    deleteOnly
                case 1:
                    deleteAndDragSeparator
                case 2:
                    deleteAndDragSeparatorAndItem
                case 3:
                    dragItemOnly
                default:
                    EmptyView()
                }
            }
            .animation(.default, value: selectedView)
            .padding(.top)
        }
    }
    
    // MARK: - Views
    
    var deleteOnly: some View {
        DDHListView<ItemExample, RowExampleView>(
            items: ItemExample.mockItems,
            rowView: { RowExampleView(item: $0) },
            onDelete: { item in
                print("Deleted item: \(item.name)")
            },
            deleteView: { DeleteExampleView() },
            isDeletionEnabled: true,
            isDropOnSeparatorEnabled: false,
            isDropOnItemEnabled: false,
            hoverColor: .blue
        )
    }
    
    var deleteAndDragSeparator: some View {
        DDHListView<ItemExample, RowExampleView>(
            items: ItemExample.mockItems,
            rowView: { RowExampleView(item: $0) },
            onDelete: { item in
                print("Deleted item: \(item.name)")
            },
            onItemDroppedOnSeparator: { dragged, above, below in
                if let above = above, let below = below {
                    print("Dragged \(dragged.name) dropped between \(above.name) and \(below.name)")
                } else if let above = above {
                    print("Dragged \(dragged.name) dropped below \(above.name)")
                } else if let below = below {
                    print("Dragged \(dragged.name) dropped above \(below.name)")
                } else {
                    print("Dragged \(dragged.name) dropped on empty list")
                }
            },
            isDeletionEnabled: true,
            isDropOnSeparatorEnabled: true,
            isDropOnItemEnabled: false,
            hoverColor: .orange
        )
    }

    var deleteAndDragSeparatorAndItem: some View {
        DDHListView<ItemExample, RowExampleView>(
            items: ItemExample.mockItems,
            rowView: { RowExampleView(item: $0) },
            onDelete: { item in
                print("Deleted item: \(item.name)")
            },
            onItemDroppedOnSeparator: { dragged, above, below in
                if let above = above, let below = below {
                    print("Dragged \(dragged.name) dropped between \(above.name) and \(below.name)")
                } else if let above = above {
                    print("Dragged \(dragged.name) dropped below \(above.name)")
                } else if let below = below {
                    print("Dragged \(dragged.name) dropped above \(below.name)")
                } else {
                    print("Dragged \(dragged.name) dropped on empty list")
                }
            },
            onItemDroppedOnOtherItem: { dragged, target in
                print("Dragged \(dragged.name) dropped on target \(target.name)")
            },
            isDeletionEnabled: true,
            isDropOnSeparatorEnabled: true,
            isDropOnItemEnabled: true,
            hoverColor: .green
        )
    }
    
    var dragItemOnly: some View {
        DDHListView<ItemExample, RowExampleView>(
            items: ItemExample.mockItems,
            rowView: { RowExampleView(item: $0) },
            onItemDroppedOnOtherItem: { dragged, target in
                print("Dragged \(dragged.name) dropped on target \(target.name)")
            },
            isDeletionEnabled: false,
            isDropOnSeparatorEnabled: false,
            isDropOnItemEnabled: true,
            hoverColor: .purple
        )
    }
}

#Preview {
    DDHListExamplePicker()
}
