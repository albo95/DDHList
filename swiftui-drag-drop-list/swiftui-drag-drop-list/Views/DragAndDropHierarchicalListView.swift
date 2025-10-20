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
    
    @State private var expandedItemsIDs: [ItemID]
    @State private var expandedItemsPaths: [[Int]] = []
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
    @State private var rowHeights: [[Int] : CGFloat]
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
        self.rowHeights = [[]:0]
        self.separatorView = separatorView
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
            ZStack(alignment: .top) {
                LazyVStack(spacing: .separatorHeight) {
                    Spacer()
                        .frame(height: .separatorHooverHeight)
                    
                    recursiveItemView(recursiveItems: self.items)
                        .readSize { size in
                            listWidth = size.width
                        }
                }
                
                recursiveSeparatorView(recursiveItems: self.items)
            }
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
    
    private func recursiveItemView(
        recursiveItems: [ItemType],
        path: [Int] = [],
    ) -> some View {
        ForEach(recursiveItems.indices, id: \.self) { index in
            VStack(alignment: .leading, spacing: .separatorHeight) {
                hierarchicalRowView(
                    recursiveItems: recursiveItems,
                    item: recursiveItems[index],
                    path: path + [index]
                )
                
                if !recursiveItems[index].childrens.isEmpty, expandedItemsIDs.contains([recursiveItems[index].id]) {
                    AnyView(recursiveItemView(
                        recursiveItems: recursiveItems[index].childrens,
                        path: path + [index],
                    ))
                    .padding(.leading, 50)
                }
            }
        }
    }
    
    private func recursiveSeparatorView (
        recursiveItems: [ItemType],
        path: [Int] = [],
    ) -> some View {
        ZStack(alignment: .top) {
            if path.isEmpty {
                GeometryReader { geo in
                    separatorView(recursiveItems: recursiveItems, path: path + [-1])
                        .position(x: geo.size.width / 2, y: .separatorHooverHeight)
                }
            }
            
            ForEach(recursiveItems.indices, id: \.self) { index in
                if !path.isEmpty && index == 0 {
                    separatorView(recursiveItems: recursiveItems, path: path + [-1])
                        .offset(y: rowHeights.totalOffset(for: path + [index], expandedPaths: expandedItemsPaths) - (rowHeights[path + [index]] ?? 0) - .separatorHeight)
                }
                
                separatorView(recursiveItems: recursiveItems, path: path + [index])
                    .offset(y: rowHeights.totalOffset(for: path + [index], expandedPaths: expandedItemsPaths))
                                
                if !recursiveItems[index].childrens.isEmpty, expandedItemsIDs.contains([recursiveItems[index].id]) {
                    AnyView(recursiveSeparatorView(
                        recursiveItems: recursiveItems[index].childrens,
                        path: path + [index],
                    ))
                    .padding(.leading, 50)
                }
            }
        }
    }
    
    private func hierarchicalRowView(recursiveItems: [ItemType], item: ItemType, path: [Int]) -> some View {
       // ZStack {
            HStack {
                if let lastPathElement = path.last {
                    Button(action: {
                        withAnimation {
                            toggleElementExpanded(itemID: item.id, path: path)
                        }
                    }, label: {
                        Image(systemName: "chevron.down")
                            .rotationEffect(Angle(degrees:
                                                    expandedItemsIDs.contains(item.id) ? 0 : -90))
                    })
                    .opacity(item.childrens.isEmpty ? 0 : 1)
                    
                    hierarchicalRowWrapper(for: recursiveItems[lastPathElement], path: path)
                }
            }
            .readSize { size in
                rowHeights[path] = size.height
            }
            
//            Text("\(path)")
//                .frame(maxWidth: .infinity, alignment: .trailing)
       // }
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
        return
//        ZStack {
//            Text("\(path)")
//                .font(.caption)
//                .frame(maxWidth: .infinity, alignment: .leading)
            
            DragAndDropListSeparatorView(isTargeted: dropTargetPath == path, isHidden: false, separatorView: separatorView.map { AnyView($0()) })
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
                    guard currentlyDraggedPath != path, currentlyDraggedPath != path.incrementLast() else { return }
                    dropTargetPath = value ? path : []
                }
                .padding(.leading, 30)
        //}
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
    
    private func toggleElementExpanded(itemID: ItemID, path: [Int]) {
        if let index = expandedItemsIDs.firstIndex(of: itemID) {
            expandedItemsIDs.remove(at: index)
            expandedItemsPaths.removeAll { $0 == path }
        } else {
            expandedItemsIDs.append(itemID)
            expandedItemsPaths.append(path)
        }
    }
}
