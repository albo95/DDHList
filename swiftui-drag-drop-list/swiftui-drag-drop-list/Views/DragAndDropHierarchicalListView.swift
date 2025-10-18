//
//  DragAndDropHierarchicalListView.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 16/10/25.
//

import Foundation
import SwiftUI
import CoreTransferable

protocol HierarchicalItemType: Transferable & Identifiable {
    var childrens: [Self] { get set }
}

struct DragAndDropHierarchicalListView<ItemType: HierarchicalItemType, RowView: View>: View {
    var items: [ItemType]
    let rowView: (ItemType) -> RowView
    let isDeleteRowEnabled: Bool
    let onDelete: (ItemType) -> Void
    let isDragAndDropEnabled: Bool
    let onItemDroppedOnSeparator: (ItemType, ItemType, ItemType) -> Void
    let isDragAndDropOnOtherItemsEnabled: Bool
    let onItemDroppedOnOtherItem: (ItemType, ItemType) -> Void
    let colorOnHover: Color
    
    @State private var dragTargetPath: [Int] = []
    @State private var dropTargetPath: [Int] = []
    @State private var currentlySwipedRowPath: [Int] = []
    @State private var currentlyDraggedPath: [Int] = []
    @State private var currentlyDraggedItem: ItemType? = nil
    @State private var lastDraggedItem: ItemType? = nil
    @State private var isScrollDisabled: Bool = true
    @State private var totalTranslationWidth: CGFloat = 0
    @State private var totalTranslationHeight: CGFloat = 0
    @State private var hideCurrentItem: Bool = false
    @State private var rowSemiHeights: [[Int] : CGFloat]
    @State private var listWidth: CGFloat = 0
    
    private init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        isDeleteRowEnabled: Bool = true,
        onDelete: @escaping (ItemType) -> Void = { _ in },
        isDragAndDropEnabled: Bool = true,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType,
            _ belowItem: ItemType
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
        self.isDragAndDropEnabled = isDragAndDropEnabled
        self.onItemDroppedOnSeparator = onItemDroppedOnSeparator
        self.isDragAndDropOnOtherItemsEnabled = isDragAndDropOnOtherItemsEnabled
        self.onItemDroppedOnOtherItem = onItemDroppedOnOtherItem
        self.colorOnHover = colorOnHover
        self.rowSemiHeights = [[]:0]
    }
    
    // MARK: - Convenience initializers
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onDelete: @escaping (ItemType) -> Void,
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
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType,
            _ belowItem: ItemType
        ) -> Void = { _, _, _ in },
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
            _ aboveItem: ItemType,
            _ belowItem: ItemType
        ) -> Void = { _, _, _ in },
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
        onDelete: @escaping (ItemType) -> Void,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType,
            _ belowItem: ItemType
        ) -> Void = { _, _, _ in },
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
        onDelete: @escaping (ItemType) -> Void,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType,
            _ belowItem: ItemType
        ) -> Void = { _, _, _ in },
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
            VStack(spacing: 0) {
                recursiveView(recursiveItems: self.items)
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
    
    private func recursiveView(
        recursiveItems: [ItemType],
        path: [Int] = [],
        showTopSeparator: Bool = true
    ) -> some View {
        ForEach(recursiveItems.indices, id: \.self) { index in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    if !recursiveItems[index].childrens.isEmpty {
                        Image(systemName: "chevron.down")
                    }
                    
                    rowView(
                        recursiveItems: recursiveItems,
                        item: recursiveItems[index],
                        path: path + [index],
                        showTopSeparator: showTopSeparator
                    )
                }
                
                if !recursiveItems[index].childrens.isEmpty {
                    AnyView(recursiveView(
                        recursiveItems: recursiveItems[index].childrens,
                        path: path + [index],
                        showTopSeparator: false
                    ))
                    .padding(.leading, 20)
                }
            }
        }
    }
    
    private func rowView(recursiveItems: [ItemType], item: ItemType, path: [Int], showTopSeparator: Bool = true) -> some View {
        ZStack {
            if path.first == 1, showTopSeparator {
                separatorView(
                    belowItem: recursiveItems[0],
                    path: path.withLast(-1),
                    isOnTop: true,
                    onDrop: resetDragging
                ).zIndex(1)
            }
            
            if let lastPathElement = path.last {
                rowWrapper(for: recursiveItems[lastPathElement], path: path)
                    .zIndex(0)
                    .readSize { size in
                        rowSemiHeights[path] = size.height / 2
                    }
                
                let belowItem = lastPathElement + 1 < recursiveItems.count ? recursiveItems[lastPathElement + 1] : nil
                
                separatorView(
                    aboveItem: recursiveItems[lastPathElement],
                    belowItem: belowItem,
                    path: path,
                    onDrop: resetDragging
                ).zIndex(1)
            }
        }
    }
    
    private func onDrag(path: [Int]) {
        resetSwiping()
        currentlyDraggedPath = path
    }
    
    private func resetSwiping() {
        currentlySwipedRowPath = []
    }
    
    private func resetDragging() {
        currentlyDraggedPath = []
        currentlyDraggedPath = []
        currentlyDraggedItem = nil
        hideCurrentItem = false
    }
    
    // MARK: - Row Wrapper
    private func rowWrapper(for item: ItemType, path: [Int]) -> some View {
        HStack {
            HierarchicalRowWrapper(
                path: path,
                item: item,
                currentlySwipedRowPath: $currentlySwipedRowPath,
                currentlyDraggedItem: $currentlyDraggedItem,
                lastDraggedItem: $lastDraggedItem,
                hideCurrentItem: $hideCurrentItem,
                isDeletionEnable: isDeleteRowEnabled,
                onDelete: { onDelete(item) },
                content: rowView,
                onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
                colorOnHover: colorOnHover,
                onDrag: {
                    onDrag(path: path)
                },
                onDrop: resetDragging,
                canBeDraggedOn: isDragAndDropOnOtherItemsEnabled,
                isDragAndDropEnabled: isDragAndDropEnabled,
                rowWidth: listWidth
            )
            .padding(.vertical, 1)
        }
    }
    
    // MARK: - Separator View
    private func separatorView(aboveItem: ItemType? = nil, belowItem: ItemType? = nil, path: [Int], isOnTop: Bool = false, onDrop: @escaping () -> Void = {})-> some View {
        
        SeparatorView(isTargeted: dropTargetPath == path, isHidden: false)
            .dropDestination(for: ItemType.self) { draggedItem, location in
                defer {
                    onDrop()
                }
                lastDraggedItem = draggedItem.first
                
                if let firstDraggedItem = draggedItem.first, let aboveItem, let belowItem {
                    onItemDroppedOnSeparator(firstDraggedItem, aboveItem, belowItem)
                }
                
                return true
            } isTargeted: { value in
                hideCurrentItem = true
                guard currentlyDraggedPath != path, currentlyDraggedPath != path.incrementLast() else { return }
                dropTargetPath = value ? path : []
            }
            .offset(y: (isOnTop ? -(rowSemiHeights[path.withLast(0)] ?? 0) : rowSemiHeights[path]) ?? 0)
    }
}
