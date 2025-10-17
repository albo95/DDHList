//
//  DragAndDropHierarchicalListView.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 17/10/25.
//

import SwiftUI

protocol ItemHierarchicalType: Transferable & Identifiable {
    var children: [Self] { get set }
}

struct DragAndDropHierarchicalListView<ItemType: ItemHierarchicalType, RowView: View>: View {
    var items: [ItemType]
    let rowView: (ItemType) -> RowView
    let isDeleteRowEnabled: Bool
    let onDelete: (Int) -> Void
    let isDragAndDropEnabled: Bool
    let onItemDroppedOnSeparator: (_ draggedItem: ItemType, _ aboveItem: ItemType, _ belowItem: ItemType) -> Void
    let isDragAndDropOnOtherItemsEnabled: Bool
    let onItemDroppedOnOtherItem: (_ draggedItem: ItemType, _ targetItem: ItemType) -> Void
    let colorOnHover: Color
    
    @State private var dragTargetIndex: Int? = nil
    @State private var dropTargetIndex: Int? = nil
    @State private var rowSemiHeight: CGFloat = 0
    @State private var rowWidth: CGFloat = 0
    @State private var currentlySwipedRow: Int? = nil
    @State private var currentlyDraggedIndex: Int? = nil
    @State private var currentlyDraggedItem: ItemType? = nil
    @State private var lastDraggedItem: ItemType? = nil
    @State private var isScrollDisabled: Bool = true
    @State private var totalTranslationWidth: CGFloat = 0
    @State private var totalTranslationHeight: CGFloat = 0
    @State private var hideCurrentItem: Bool = false
    
    private init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        isDeleteRowEnabled: Bool = true,
        onDelete: @escaping (Int) -> Void = { _ in },
        isDragAndDropEnabled: Bool = true,
        onItemDroppedOnSeparator: @escaping (_ draggedItem: ItemType, _ aboveItem: ItemType, _ belowItem: ItemType) -> Void = { _, _, _ in },
        isDragAndDropOnOtherItemsEnabled: Bool = true,
        onItemDroppedOnOtherItem: @escaping (_ draggedItem: ItemType, _ targetItem: ItemType) -> Void = { _, _ in },
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
    
    // MARK: - Convenience initializers
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        onDelete: @escaping (_ index: Int) -> Void,
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
        onItemDroppedOnSeparator: @escaping (_ draggedItem: ItemType, _ aboveItem: ItemType, _ belowItem: ItemType) -> Void,
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
        onItemDroppedOnSeparator: @escaping (_ draggedItem: ItemType, _ aboveItem: ItemType, _ belowItem: ItemType) -> Void,
        onItemDroppedOnOtherItem: @escaping (_ draggedItem: ItemType, _ targetItem: ItemType) -> Void,
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
        onDelete: @escaping (_ index: Int) -> Void,
        onItemDroppedOnSeparator: @escaping (_ draggedItem: ItemType, _ aboveItem: ItemType, _ belowItem: ItemType) -> Void,
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
        onDelete: @escaping (_ index: Int) -> Void,
        onItemDroppedOnSeparator: @escaping (_ draggedItem: ItemType, _ aboveItem: ItemType, _ belowItem: ItemType) -> Void,
        onItemDroppedOnOtherItem: @escaping (_ draggedItem: ItemType, _ targetItem: ItemType) -> Void,
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
                            .readSize{ size  in
                                rowSemiHeight = size.height / 2
                                rowWidth = size.width
                            }
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
        .scrollDisabled(isScrollDisabled)
        .simultaneousGesture(DragGesture().onChanged { gesture in
            totalTranslationWidth += abs(gesture.translation.width)
            totalTranslationHeight += abs(gesture.translation.height)
            isScrollDisabled = totalTranslationWidth > totalTranslationHeight
        }.onEnded {_ in
            isScrollDisabled = false
            totalTranslationWidth = 0
            totalTranslationHeight = 0
        })
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
        RowWrapper(
            index: index,
            item: item,
            currentlySwipedRow: $currentlySwipedRow,
            currentlyDraggedItem: $currentlyDraggedItem,
            lastDraggedItem: $lastDraggedItem,
            hideCurrentItem: $hideCurrentItem,
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
                   //onItemDroppedOnSeparator(firstDraggedItem, above, below)
                }
                
                return true
            } isTargeted: { value in
                hideCurrentItem = true
                guard currentlyDraggedIndex != index, currentlyDraggedIndex != index + 1 else { return }
                dropTargetIndex = value ? index : nil
            }
            .offset(y: isOnTop ? -rowSemiHeight : rowSemiHeight)
    }
}
