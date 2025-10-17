//
//  DragAndDropListView.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 16/10/25.
//

import Foundation
import SwiftUI
import CoreTransferable

struct DragAndDropListView<ItemType: Transferable & Identifiable, RowView: View>: View {
    var items: [ItemType]
    let rowView: (ItemType) -> RowView
    let isDeleteRowEnabled: Bool
    let onDelete: (Int) -> Void
    let isDragAndDropEnabled: Bool
    let onItemDroppedOnSeparator: (ItemType, Int, Int) -> Void
    let isDragAndDropOnOtherItemsEnabled: Bool
    let onItemDroppedOnOtherItem: (ItemType, ItemType) -> Void
    let colorOnHover: Color
    
    @State private var dragTargetIndex: Int? = nil
    @State private var dropTargetIndex: Int? = nil
    @State private var rowSemiHeight: CGFloat = 0
    @State private var rowWidth: CGFloat = 0
    @State private var currentlySwipedRow: Int? = nil
    @State private var currentlyDraggedIndex: Int? = nil
    @State private var currentlyDraggedItem: ItemType? = nil
    @State private var lastDraggedItem: ItemType? = nil
    
    private init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        isDeleteRowEnabled: Bool = true,
        onDelete: @escaping (Int) -> Void = { _ in },
        isDragAndDropEnabled: Bool = true,
        onItemDroppedOnSeparator: @escaping (ItemType, Int, Int) -> Void = { _, _, _ in },
        isDragAndDropOnOtherItemsEnabled: Bool = true,
        onItemDroppedOnOtherItem: @escaping (ItemType, ItemType) -> Void = { _, _ in },
        colorOnHover: Color = .blue
    ) {
        self.items = items
        self.rowView = rowView
        self.isDeleteRowEnabled = isDeleteRowEnabled
        self.onDelete = onDelete
        self.isDragAndDropEnabled = isDragAndDropEnabled
        self.onItemDroppedOnSeparator = onItemDroppedOnSeparator
        self.isDragAndDropOnOtherItemsEnabled = isDragAndDropOnOtherItemsEnabled
        self.onItemDroppedOnOtherItem = onItemDroppedOnOtherItem
        self.colorOnHover = colorOnHover
    }
    
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onDelete: @escaping (Int) -> Void,
        colorOnHover: Color = .blue
    ) {
        self.init(
            items: items,
            rowView: rowView,
            isDeleteRowEnabled: true,
            onDelete: onDelete,
            isDragAndDropEnabled: false,
            isDragAndDropOnOtherItemsEnabled: false,
            colorOnHover: colorOnHover
        )
    }
    
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onItemDroppedOnSeparator: @escaping (ItemType, Int, Int) -> Void,
        colorOnHover: Color = .blue
    ) {
        self.init(
            items: items,
            rowView: rowView,
            isDeleteRowEnabled: false,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            isDragAndDropOnOtherItemsEnabled: false,
            colorOnHover: colorOnHover
        )
    }
    
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onItemDroppedOnSeparator: @escaping (ItemType, Int, Int) -> Void,
        onItemDroppedOnOtherItem: @escaping (ItemType, ItemType) -> Void,
        colorOnHover: Color = .blue
    ) {
        self.init(
            items: items,
            rowView: rowView,
            isDeleteRowEnabled: false,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
            colorOnHover: colorOnHover
        )
    }
    
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onDelete: @escaping (Int) -> Void,
        onItemDroppedOnSeparator: @escaping (ItemType, Int, Int) -> Void,
        colorOnHover: Color = .blue
    ) {
        self.init(
            items: items,
            rowView: rowView,
            isDeleteRowEnabled: true,
            onDelete: onDelete,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            isDragAndDropOnOtherItemsEnabled: false,
            colorOnHover: colorOnHover
        )
    }
    
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onDelete: @escaping (Int) -> Void,
        onItemDroppedOnSeparator: @escaping (ItemType, Int, Int) -> Void,
        onItemDroppedOnOtherItem: @escaping (ItemType, ItemType) -> Void,
        colorOnHover: Color = .blue
    ) {
        self.init(
            items: items,
            rowView: rowView,
            isDeleteRowEnabled: true,
            onDelete: onDelete,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
            colorOnHover: colorOnHover
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let first = items.first {
                    ZStack {
                        separatorView(index: -1, isOnTop: true, onDrop: resetDragging)
                            .zIndex(10)
                        
                        rowWrapper(for: first, index: 0)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            rowSemiHeight = geo.size.height / 2
                                            rowWidth = geo.size.width
                                        }
                                }
                            )
                            .zIndex(0)
                        
                        
                        separatorView(index: 0)
                            .zIndex(1)
                    }
                }
                
                ForEach(items.indices.dropFirst(), id: \.self) { index in
                    ZStack {
                        rowWrapper(for: items[index], index: index)
                            .zIndex(0)
                        
                        separatorView(index: index, onDrop: resetDragging)
                            .zIndex(1)
                    }
                }
            }.padding(.top, .separatorHooverHeight)
        }
    }
    
    private func onDrag(index: Int) {
        resetSwiping()
        currentlyDraggedIndex = index
    }
    
    private func resetSwiping() {
        currentlySwipedRow = nil
    }
    
    private func resetDragging() {
        dropTargetIndex = nil
        currentlyDraggedIndex = nil
        currentlyDraggedItem = nil
    }
    
    // MARK: - Row Wrapper
    private func rowWrapper(for item: ItemType, index: Int) -> some View {
        RowWrapper(
            index: index,
            item: item,
            currentlySwipedRow: $currentlySwipedRow,
            currentlyDraggedItem: $currentlyDraggedItem,
            lastDraggedItem: $lastDraggedItem,
            isDeletionEnable: isDeleteRowEnabled,
            onDelete: { onDelete(index) },
            content: rowView,
            onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
            colorOnHover: colorOnHover,
            onDrag: {
                onDrag(index: index)
            },
            onDrop: resetDragging,
            canBeDraggedOn: isDragAndDropOnOtherItemsEnabled,
            isDragAndDropEnabled: isDragAndDropEnabled,
            rowWidth: rowWidth
        )
        .padding(.vertical, 1)
    }
    
    // MARK: - Separator View
    private func separatorView(index: Int, isOnTop: Bool = false, onDrop: @escaping () -> Void = {})-> some View {
        SeparatorView(isTargeted: dropTargetIndex == index, isHidden: false)
            .dropDestination(for: ItemType.self) { draggedItem, location in
                defer {
                    onDrop()
                }
                lastDraggedItem = draggedItem.first
                
                let above = index
                let below = index + 1 < items.count ? index + 1 : index
                if let firstDraggedItem = draggedItem.first {
                    onItemDroppedOnSeparator(firstDraggedItem, above, below)
                }
                return true
            } isTargeted: { value in
                guard currentlyDraggedIndex != index, currentlyDraggedIndex != index + 1 else { return }
                dropTargetIndex = value ? index : nil
            }
            .offset(y: isOnTop ? -rowSemiHeight : rowSemiHeight)
    }
}
