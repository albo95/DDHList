//
//  DragAndDropHierarchicalListView.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 16/10/25.
//

import Foundation
import SwiftUI
import CoreTransferable

protocol HierarchicalItemType: Transferable & Identifiable & Hashable {
    var childrens: [Self] { get set }
}

struct DragAndDropHierarchicalListView<ItemType: HierarchicalItemType, RowView: View>: View {
    typealias ItemID = ItemType.ID
    
    let items: [ItemType]
    let expandedItemsIDs: [ItemID]
    let rowView: (ItemType) -> RowView
    let deleteView: (() -> any View)?
    let isDeleteRowEnabled: Bool
    let onDelete: (ItemType) -> Void
    let isDragAndDropEnabled: Bool
    let onItemDroppedOnSeparator: (ItemType, ItemType?, ItemType?) -> Void
    let isDragAndDropOnOtherItemsEnabled: Bool
    let onItemDroppedOnOtherItem: (ItemType, ItemType) -> Void
    let colorOnHover: Color
    let separatorView: (() -> any View)?
    
    @State private var itemsExpandInfo: [ItemID: Bool]
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
        expandedItemsIDs: [ItemID] = [],
        rowView: @escaping (ItemType) -> RowView,
        deleteView: (() -> any View)? = nil,
        isDeleteRowEnabled: Bool = true,
        onDelete: @escaping (ItemType) -> Void = { _ in },
        isDragAndDropEnabled: Bool = true,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType?,
            _ belowItem: ItemType?
        ) -> Void = { _, _, _ in },
        isDragAndDropOnOtherItemsEnabled: Bool = true,
        onItemDroppedOnOtherItem: @escaping (
            _ draggedItem: ItemType,
            _ targetItem: ItemType
        ) -> Void = { _, _ in },
        colorOnHover: Color = .blue,
        separatorView: (() -> any View)? = nil
    ) {
        self.items = items
        self.expandedItemsIDs = expandedItemsIDs
        self.rowView = rowView
        self.isDeleteRowEnabled = isDeleteRowEnabled
        self.onDelete = onDelete
        self.deleteView = deleteView
        self.isDragAndDropEnabled = isDragAndDropEnabled
        self.onItemDroppedOnSeparator = onItemDroppedOnSeparator
        self.isDragAndDropOnOtherItemsEnabled = isDragAndDropOnOtherItemsEnabled
        self.onItemDroppedOnOtherItem = onItemDroppedOnOtherItem
        self.colorOnHover = colorOnHover
        self.rowSemiHeights = [[]:0]
        self.separatorView = separatorView
        self._itemsExpandInfo = State(initialValue: [:])
        self._itemsExpandInfo = State(initialValue: getItemsOpenInfo(items: items))
    }
    
    // MARK: - Convenience initializers
    init(
        items: [ItemType],
        expandedItemsIDs: [ItemID] = [],
        rowView: @escaping (ItemType) -> RowView,
        onDelete: @escaping (ItemType) -> Void,
        deleteView: (() -> any View)? = nil,
        isDragAndDropEnabled: Bool = true,
        colorOnHover: Color = .blue,
        separatorView: (() -> any View)? = nil
    ) {
        self.init(
            items: items,
            expandedItemsIDs: expandedItemsIDs,
            rowView: rowView,
            deleteView: deleteView,
            isDeleteRowEnabled: true,
            onDelete: onDelete,
            isDragAndDropEnabled: isDragAndDropEnabled,
            isDragAndDropOnOtherItemsEnabled: false,
            colorOnHover: colorOnHover
        )
    }
    
    init(
        items: [ItemType],
        expandedItemsIDs: [ItemID] = [],
        rowView: @escaping (ItemType) -> RowView,
        isDragAndDropEnabled: Bool = true,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType?,
            _ belowItem: ItemType?
        ) -> Void = { _, _, _ in },
        colorOnHover: Color = .blue,
        separatorView: (() -> any View)? = nil
    ) {
        self.init(
            items: items,
            expandedItemsIDs: expandedItemsIDs,
            rowView: rowView,
            isDeleteRowEnabled: false,
            isDragAndDropEnabled: isDragAndDropEnabled,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            isDragAndDropOnOtherItemsEnabled: false,
            colorOnHover: colorOnHover,
            separatorView: separatorView
        )
    }
    
    init(
        items: [ItemType],
        expandedItemsIDs: [ItemID] = [],
        rowView: @escaping (ItemType) -> RowView,
        isDragAndDropEnabled: Bool = true,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType?,
            _ belowItem: ItemType?
        ) -> Void = { _, _, _ in },
        onItemDroppedOnOtherItem: @escaping (
            _ draggedItem: ItemType,
            _ targetItem: ItemType
        ) -> Void,
        colorOnHover: Color = .blue,
        separatorView: (() -> any View)? = nil
    ) {
        self.init(
            items: items,
            expandedItemsIDs: expandedItemsIDs,
            rowView: rowView,
            isDeleteRowEnabled: false,
            isDragAndDropEnabled: isDragAndDropEnabled,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
            colorOnHover: colorOnHover,
            separatorView: separatorView
        )
    }
    
    init(
        items: [ItemType],
        expandedItemsIDs: [ItemID] = [],
        rowView: @escaping (ItemType) -> RowView,
        isDragAndDropEnabled: Bool = true,
        onDelete: @escaping (ItemType) -> Void,
        deleteView: (() -> any View)? = nil,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType?,
            _ belowItem: ItemType?
        ) -> Void = { _, _, _ in },
        colorOnHover: Color = .blue,
        separatorView: (() -> any View)? = nil
    ) {
        self.init(
            items: items,
            expandedItemsIDs: expandedItemsIDs,
            rowView: rowView,
            deleteView: deleteView,
            isDeleteRowEnabled: true,
            onDelete: onDelete,
            isDragAndDropEnabled: isDragAndDropEnabled,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            isDragAndDropOnOtherItemsEnabled: false,
            colorOnHover: colorOnHover,
            separatorView: separatorView
        )
    }
    
    init(
        items: [ItemType],
        expandedItemsIDs: [ItemID] = [],
        rowView: @escaping (ItemType) -> RowView,
        isDragAndDropEnabled: Bool = true,
        onDelete: @escaping (ItemType) -> Void,
        deleteView: (() -> any View)? = nil,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType?,
            _ belowItem: ItemType?
        ) -> Void = { _, _, _ in },
        onItemDroppedOnOtherItem: @escaping (
            _ draggedItem: ItemType,
            _ targetItem: ItemType
        ) -> Void,
        colorOnHover: Color = .blue,
        separatorView: (() -> any View)? = nil
    ) {
        self.init(
            items: items,
            expandedItemsIDs: expandedItemsIDs,
            rowView: rowView,
            deleteView: deleteView,
            isDeleteRowEnabled: true,
            onDelete: onDelete,
            isDragAndDropEnabled: isDragAndDropEnabled,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
            colorOnHover: colorOnHover,
            separatorView: separatorView
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
            .padding(.vertical, .separatorHooverHeight)
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
                    hierarchicalRowView(
                        recursiveItems: recursiveItems,
                        item: recursiveItems[index],
                        path: path + [index]
                    )
                }
                
                if !recursiveItems[index].childrens.isEmpty, itemsExpandInfo[recursiveItems[index].id] == true {
                    AnyView(recursiveView(
                        recursiveItems: recursiveItems[index].childrens,
                        path: path + [index],
                    ))
                    .padding(.leading, 50)
                }
            }
        }
    }
    
    private func hierarchicalRowView(recursiveItems: [ItemType], item: ItemType, path: [Int]) -> some View {
        ZStack {
            if path.last == 0 {
                separatorView(
                    recursiveItems: recursiveItems,
                    path: path.withLast(-1),
                    onDrop: resetDragging
                ).zIndex(1)
            }
            
            if let lastPathElement = path.last {
                HStack {
                    Button(action: {
                        withAnimation {
                            itemsExpandInfo[item.id]?.toggle()
                        }
                    }, label: {
                        Image(systemName: "chevron.down")
                            .rotationEffect(Angle(degrees:
                                                    itemsExpandInfo[item.id] == true ? 0 : -90))
                    })
                    .opacity(item.childrens.isEmpty ? 0 : 1)
                    
                    hierarchicalRowWrapper(for: recursiveItems[lastPathElement], path: path)
                        .zIndex(0)
                        .readSize { size in
                            rowSemiHeights[path] = size.height / 2
                        }
                    
                    //                    Text("\(path)")
                    //                        .font(.caption)
                }
                
                separatorView(
                    recursiveItems: recursiveItems,
                    path: path,
                    onDrop: resetDragging
                )
                .padding(.leading, 30)
                .zIndex(1)
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
    private func hierarchicalRowWrapper(for item: ItemType, path: [Int]) -> some View {
        DragAndDropHierarchicalListRowWrapper(
            path: path,
            item: item,
            currentlySwipedRowPath: $currentlySwipedRowPath,
            currentlyDraggedItem: $currentlyDraggedItem,
            lastDraggedItem: $lastDraggedItem,
            hideCurrentItem: $hideCurrentItem,
            isDeletionEnable: isDeleteRowEnabled,
            deleteView: deleteView.map { AnyView($0()) },
            onDelete: { onDelete(item) },
            content: rowView,
            onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
            colorOnHover: colorOnHover,
            onDrag: { onDrag(path: path) },
            onDrop: resetDragging,
            canBeDraggedOn: isDragAndDropOnOtherItemsEnabled,
            isDragAndDropEnabled: isDragAndDropEnabled,
            rowWidth: listWidth
        ).padding(.vertical, 1)
    }
    
    // MARK: - Separator View
    private func separatorView(recursiveItems: [ItemType], path: [Int], onDrop: @escaping () -> Void = {})-> some View {
        let isAboveFirstItem = path.last == -1
        let isBelowLastItem = path.last == recursiveItems.count - 1
        return DragAndDropListSeparatorView(isTargeted: dropTargetPath == path, isHidden: false, separatorView: separatorView.map { AnyView($0()) })
            .dropDestination(for: ItemType.self) { draggedItem, location in
                defer {
                    onDrop()
                }
                
                lastDraggedItem = draggedItem.first
                
                if let firstDraggedItem = draggedItem.first {
                    var aboveItem: ItemType? = nil
                    var belowItem: ItemType? = nil
                    
                    if isAboveFirstItem {
                        aboveItem = nil
                    } else if let pathLast = path.last, recursiveItems.count > pathLast + 1{
                        aboveItem = recursiveItems[pathLast]
                    }
                    
                    if isBelowLastItem {
                        belowItem = nil
                    } else if let pathLast = path.last {
                        belowItem = recursiveItems[pathLast + 1]
                    }
                    
                    onItemDroppedOnSeparator(firstDraggedItem, aboveItem, belowItem)
                }
                
                return true
            } isTargeted: { value in
                hideCurrentItem = true
                guard currentlyDraggedPath != path, currentlyDraggedPath != path.decrementLast() else { return }
                dropTargetPath = value ? path : []
            }
            .offset(y: (isAboveFirstItem ? -(rowSemiHeights[path.withLast(0)] ?? 0) : rowSemiHeights[path]) ?? 0)
    }
    
    private func getItemsOpenInfo(items: [ItemType]) -> [ItemID: Bool] {
        var newExpandInfo: [ItemID: Bool] = [:]
        
        func process(items: [ItemType]) {
            for item in items {
                newExpandInfo[item.id] = expandedItemsIDs.contains(item.id)
                if !item.childrens.isEmpty {
                    process(items: item.childrens)
                }
            }
        }
        
        process(items: items)
        return newExpandInfo
    }
}
