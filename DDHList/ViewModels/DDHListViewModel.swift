//
//  DDHListViewModel.swift
//  DDHList
//
//  Created by Alberto Bruno on 21/10/25.
//

import Foundation
import SwiftUI

class DDHListViewModel<ItemType: DDHItem>: ObservableObject {
    let items: [ItemType]
    let onDelete: (ItemType) -> Void
    let onItemDroppedOnSeparator: (_ draggedItem: ItemType, _ aboveItem: ItemType?, _ belowItem: ItemType?) -> Void
    let onItemDroppedOnOtherItem: (_ draggedItem: ItemType, _ targetItem: ItemType) -> Void
    let hoverColor: Color
    let isDropOnSeparatorEnabled: Bool
    let isDropOnItemEnabled: Bool
    let isDeletionEnabled: Bool
    
    var lastDroppedItem: ItemType? = nil
    
    @Published var itemsInList: [ItemPath: ItemType] = [:]
    @Published var aboveDropTargetPath: ItemPath? = nil
    @Published var belowDropTargetPath: ItemPath? = nil
    @Published var expandedItemsIDs: [ItemType.ID] = [] {
        didSet {
            updateItemsInList()
        }
    }
    @Published var currentlySwipedRowPath: ItemPath? = nil
    @Published var targetItem: ItemType? = nil
    @Published var draggedItem: ItemType? = nil {
        didSet {
            if draggedItem != nil {
                resetRowSwiping()
            }
        }
    }
    @Published var lastDraggedItem: ItemType? = nil
    
    private var isFirstOnDrag: Bool = true
    
    var targetItemPath: ItemPath? {
        guard let targetItem else { return nil }
        return itemsInList.first { $0.value.id == targetItem.id }?.key
    }
    
    var draggedItemPath: ItemPath? {
        guard let draggedItem else { return nil }
        return itemsInList.first { $0.value.id == draggedItem.id }?.key
    }
    
    init(items: [ItemType],
         onDelete: @escaping (ItemType) -> Void = {_ in},
         onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType?,
            _ belowItem: ItemType?
         ) -> Void = { _, _, _ in },
         onItemDroppedOnOtherItem: @escaping (
            _ draggedItem: ItemType,
            _ targetItem: ItemType
         ) -> Void = { _, _ in },
         isDropOnSeparatorEnabled: Bool = true,
         isDropOnItemEnabled: Bool = true,
         isDeletionEnabled: Bool = true,
         hoverColor: Color = .blue) {
        self.items = items
        self.onDelete = onDelete
        self.onItemDroppedOnSeparator = onItemDroppedOnSeparator
        self.onItemDroppedOnOtherItem = onItemDroppedOnOtherItem
        self.hoverColor = hoverColor
        self.isDropOnSeparatorEnabled = isDropOnSeparatorEnabled
        self.isDropOnItemEnabled = isDropOnItemEnabled
        self.isDeletionEnabled = isDeletionEnabled
        self.updateItemsInList()
    }
    
    func updateItemsInList() {
        itemsInList.removeAll()
        
        func traverse(items: [ItemType], path: ItemPath = []) {
            for (index, item) in items.enumerated() {
                let currentPath = path + [index]
                itemsInList[currentPath] = item
                
                if !item.children.isEmpty && expandedItemsIDs.contains(item.id) {
                    traverse(items: item.children, path: currentPath)
                }
            }
        }
        
        traverse(items: items)
    }
    
    func resetTargets() {
        targetItem = nil
        aboveDropTargetPath = nil
        belowDropTargetPath = nil
    }
    
    func toggleElementExpanded(itemID: ItemType.ID) {
        if let index = expandedItemsIDs.firstIndex(of: itemID) {
            expandedItemsIDs.remove(at: index)
        } else {
            expandedItemsIDs.append(itemID)
        }
        
        self.updateItemsInList()
    }
    
    func resetRowSwiping() {
        currentlySwipedRowPath = []
    }
    
    func onDrag(_ item: ItemType) {
        if lastDroppedItem == item {
            draggedItem = nil
            lastDroppedItem = nil
        } else {
            draggedItem = item
        }
        
        resetTargets()
        resetRowSwiping()
    }
    
    func onDrop() {
        if let targetItem, isDropOnItemEnabled, let draggedItem {
            onItemDroppedOnOtherItem(draggedItem, targetItem)
        } else if isDropOnSeparatorEnabled, let draggedItem {
            let aboveItem = aboveDropTargetPath.flatMap { itemsInList[$0] }
            let belowItem = belowDropTargetPath.flatMap { itemsInList[$0] }
            
            onItemDroppedOnSeparator(draggedItem, aboveItem, belowItem)
        }
        
        lastDroppedItem = draggedItem
        resetTargets()
        resetRowSwiping()
    }
    
    func isItemOfPathExpanded(_ path: ItemPath?) -> Bool {
        guard let path, let item = itemsInList[path] else { return false }
        return expandedItemsIDs.contains(item.id)
    }
    
    func doesItemExist(at path: ItemPath?) -> Bool {
        guard let path else { return false }
        return itemsInList[path] != nil
    }
}
