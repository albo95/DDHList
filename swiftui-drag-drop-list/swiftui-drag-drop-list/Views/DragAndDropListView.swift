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
    let deleteView: (() -> any View)?
    let isDragAndDropEnabled: Bool
    let onItemDroppedOnSeparator: (ItemType, Int, Int) -> Void
    let isDragAndDropOnOtherItemsEnabled: Bool
    let onItemDroppedOnOtherItem: (ItemType, ItemType) -> Void
    let colorOnHover: Color
    
    @State private var dragTargetIndex: Int? = nil
    @State private var dropTargetIndex: Int? = nil
    @State private var currentlySwipedRow: Int? = nil
    @State private var currentlyDraggedIndex: Int? = nil
    @State private var currentlyDraggedItem: ItemType? = nil
    @State private var lastDraggedItem: ItemType? = nil
    @State private var isScrollDisabled: Bool = true
    @State private var totalTranslationWidth: CGFloat = 0
    @State private var totalTranslationHeight: CGFloat = 0
    @State private var hideCurrentItem: Bool = false
    @State private var rowSemiHeights: [CGFloat]
    @State private var listWidth: CGFloat = 0
    
    private init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        isDeleteRowEnabled: Bool = true,
        onDelete: @escaping (Int) -> Void = { _ in },
        deleteView: (() -> any View)? = nil,
        isDragAndDropEnabled: Bool = true,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveIndex: Int,
            _ belowIndex: Int
        ) -> Void = { _, _, _ in },
        isDragAndDropOnOtherItemsEnabled: Bool = true,
        onItemDroppedOnOtherItem: @escaping (
            _ draggedItem: ItemType,
            _ targetItem: ItemType
        ) -> Void = { _, _ in },
        colorOnHover: Color = .blue
    ) {
        self.items = items
        self.rowView = rowView
        self.isDeleteRowEnabled = isDeleteRowEnabled
        self.onDelete = onDelete
        self.deleteView = deleteView
        self.isDragAndDropEnabled = isDragAndDropEnabled
        self.onItemDroppedOnSeparator = onItemDroppedOnSeparator
        self.isDragAndDropOnOtherItemsEnabled = isDragAndDropOnOtherItemsEnabled
        self.onItemDroppedOnOtherItem = onItemDroppedOnOtherItem
        self.colorOnHover = colorOnHover
        self.rowSemiHeights = Array(repeating: 0, count: items.count)
    }
    
    // MARK: - Convenience initializers
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onDelete: @escaping (Int) -> Void,
        deleteView: (() -> any View)? = nil,
        colorOnHover: Color = .blue
    ) {
        self.init(
            items: items,
            rowView: rowView,
            isDeleteRowEnabled: true,
            onDelete: onDelete,
            deleteView: deleteView,
            isDragAndDropEnabled: false,
            isDragAndDropOnOtherItemsEnabled: false,
            colorOnHover: colorOnHover
        )
    }
    
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveIndex: Int,
            _ belowIndex: Int
        ) -> Void,
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
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveIndex: Int,
            _ belowIndex: Int
        ) -> Void,
        onItemDroppedOnOtherItem: @escaping (
            _ draggedItem: ItemType,
            _ targetItem: ItemType
        ) -> Void,
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
        deleteView: (() -> any View)? = nil,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveIndex: Int,
            _ belowIndex: Int
        ) -> Void,
        colorOnHover: Color = .blue
    ) {
        self.init(
            items: items,
            rowView: rowView,
            isDeleteRowEnabled: true,
            onDelete: onDelete,
            deleteView: deleteView,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            isDragAndDropOnOtherItemsEnabled: false,
            colorOnHover: colorOnHover
        )
    }
    
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onDelete: @escaping (Int) -> Void,
        deleteView: (() -> any View)? = nil,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveIndex: Int,
            _ belowIndex: Int
        ) -> Void,
        onItemDroppedOnOtherItem: @escaping (
            _ draggedItem: ItemType,
            _ targetItem: ItemType
        ) -> Void,
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
            LazyVStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    rowView(item: items[index], index: index)
                }
            }
            .readSize { size in
                listWidth = size.width
            }
            .padding(.top, .separatorHooverHeight)
        }
        .scrollDisabled(isScrollDisabled)
        .simultaneousGesture(DragGesture().onChanged { gesture in
            totalTranslationWidth += abs(gesture.translation.width)
            totalTranslationHeight += abs(gesture.translation.height)
            isScrollDisabled = totalTranslationWidth > totalTranslationHeight
        }
            .onEnded {_ in
                isScrollDisabled = false
                totalTranslationWidth = 0
                totalTranslationHeight = 0
            })
    }
    
    private func rowView(item: ItemType, index: Int) -> some View {
        ZStack {
            if index == 0 {
                separatorView(index: -1, isOnTop: true, onDrop: resetDragging)
                    .zIndex(1)
            }
            
            rowWrapper(for: items[index], index: index)
                .zIndex(0)
                .readSize { size in
                    rowSemiHeights[index] = size.height / 2
                }
            
            separatorView(index: index, onDrop: resetDragging)
                .zIndex(1)
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
        hideCurrentItem = false
    }
    
    // MARK: - Row Wrapper
    private func rowWrapper(for item: ItemType, index: Int) -> some View {
        DragAndDropListRowWrapper(
            index: index,
            item: item,
            currentlySwipedRow: $currentlySwipedRow,
            currentlyDraggedItem: $currentlyDraggedItem,
            lastDraggedItem: $lastDraggedItem,
            hideCurrentItem: $hideCurrentItem,
            isDeletionEnable: isDeleteRowEnabled,
            onDelete: { onDelete(index) },
            deleteView: deleteView.map { AnyView($0()) },
            content: rowView,
            onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
            colorOnHover: colorOnHover,
            onDrag: {
                onDrag(index: index)
            },
            onDrop: resetDragging,
            canBeDraggedOn: isDragAndDropOnOtherItemsEnabled,
            isDragAndDropEnabled: isDragAndDropEnabled,
            rowWidth: listWidth
        )
        .padding(.vertical, 1)
    }
    
    // MARK: - Separator View
    private func separatorView(index: Int, isOnTop: Bool = false, onDrop: @escaping () -> Void = {})-> some View {
        DragAndDropListSeparatorView(isTargeted: dropTargetIndex == index, isHidden: false)
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
                hideCurrentItem = true
                guard currentlyDraggedIndex != index, currentlyDraggedIndex != index + 1 else { return }
                dropTargetIndex = value ? index : nil
            }
            .offset(y: isOnTop ? -rowSemiHeights[0] : rowSemiHeights[index])
    }
}
