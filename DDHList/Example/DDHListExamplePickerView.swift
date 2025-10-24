//
//  DDHListExamplePickerView.swift
//  DDHList
//
//  Created by Alberto Bruno on 22/10/25.
//

import SwiftUI

@available(iOS 16.0, *)
struct DDHListExamplePickerView: View {
    @State private var selectedView: Int = 0
    @State private var itemsDeleteOnly = ItemExample.mockItems
    @State private var itemsDeleteAndDragSeparator = ItemExample.mockItems
    @State private var itemsDeleteAndDragSeparatorAndItem = ItemExample.mockItems
    @State private var itemsDragItemOnly = ItemExample.mockItems

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

            Group {
                switch selectedView {
                case 0: deleteOnly
                case 1: deleteAndDragSeparator
                case 2: deleteAndDragSeparatorAndItem
                case 3: dragItemOnly
                default: EmptyView()
                }
            }
            .animation(.default, value: selectedView)
            .padding(.top)
        }
    }

    // MARK: - Views
    var deleteOnly: some View {
        DDHListView<ItemExample, RowExampleView>(
            items: $itemsDeleteOnly,
            rowView: { RowExampleView(item: $0) },
            onDelete: { item in print("Deleted item: \(item.name)") },
            deleteView: { DeleteExampleView() },
            hoverColor: .blue,
            isDeletionEnabled: .constant(true),
            isDropOnSeparatorEnabled: .constant(false),
            isDropOnItemEnabled: .constant(false)
        )
    }

    var deleteAndDragSeparator: some View {
        DDHListView<ItemExample, RowExampleView>(
            items: $itemsDeleteAndDragSeparator,
            rowView: { RowExampleView(item: $0) },
            onDelete: { item in print("Deleted item: \(item.name)") },
            onItemDroppedOnSeparator: { dragged, above, below in
                print("Dragged \(dragged.name) dropped between \(above?.name ?? "nil") and \(below?.name ?? "nil")")
            },
            hoverColor: .orange,
            isDeletionEnabled: .constant(true),
            isDropOnSeparatorEnabled: .constant(true),
            isDropOnItemEnabled: .constant(false)
        )
    }

    var deleteAndDragSeparatorAndItem: some View {
        DDHListView<ItemExample, RowExampleView>(
            items: $itemsDeleteAndDragSeparatorAndItem,
            rowView: { RowExampleView(item: $0) },
            onDelete: { item in print("Deleted item: \(item.name)") },
            onItemDroppedOnSeparator: { dragged, above, below in
                print("Dragged \(dragged.name) dropped between \(above?.name ?? "nil") and \(below?.name ?? "nil")")
            },
            onItemDroppedOnOtherItem: { dragged, target in
                print("Dragged \(dragged.name) dropped on target \(target.name)")
            },
            hoverColor: .green,
            isDeletionEnabled: .constant(true),
            isDropOnSeparatorEnabled: .constant(true),
            isDropOnItemEnabled: .constant(true)
        )
    }

    var dragItemOnly: some View {
        DDHListView<ItemExample, RowExampleView>(
            items: $itemsDragItemOnly,
            rowView: { RowExampleView(item: $0) },
            onItemDroppedOnOtherItem: { dragged, target in
                print("Dragged \(dragged.name) dropped on target \(target.name)")
            },
            hoverColor: .purple,
            isDeletionEnabled: .constant(false),
            isDropOnSeparatorEnabled: .constant(false),
            isDropOnItemEnabled: .constant(true)
        )
    }
}
