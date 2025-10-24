//
//  DDListViewModel.swift
//  DDList
//
//  Created by Alberto Bruno on 21/10/25.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 16.0, *)
class DDHListViewModel<ItemType: Transferable & Identifiable & Equatable>: ObservableObject {
    let onDelete: (ItemType) -> Void
    let onItemDroppedOnSeparator: (_ draggedItem: ItemType, _ aboveItem: ItemType?, _ belowItem: ItemType?) -> Void
    let onItemDroppedOnOtherItem: (_ draggedItem: ItemType, _ targetItem: ItemType) -> Void
    let hoverColor: Color
    
    var lastDroppedItem: ItemType? = nil
    
    @Published var items: [ItemType] = [] {
        didSet {
            updateItemsInList()
        }
    }
    @Published var isDeletionEnabled: Bool = true
    @Published var isDropOnSeparatorEnabled: Bool = true
    @Published var isDropOnItemEnabled: Bool = true
    @Published var itemsInList: [ItemPath: ItemType] = [:]
    @Published var aboveDropTargetPath: ItemPath? = nil
    @Published var belowDropTargetPath: ItemPath? = nil
    @Published var expandedItemsIDs: [ItemType.ID] = []
    @Published var currentlySwipedRowPath: ItemPath? = nil
    @Published var targetItem: ItemType? = nil
    @Published var draggedItem: ItemType? = nil {
        didSet {
            if draggedItem != nil {
                resetRowSwiping()
            }
        }
    }
        
    var targetItemPath: ItemPath? {
        guard let targetItem else { return nil }
        return itemsInList.first { $0.value.id == targetItem.id }?.key
    }
    
    var draggedItemPath: ItemPath? {
        guard let draggedItem else { return nil }
        return itemsInList.first { $0.value.id == draggedItem.id }?.key
    }
    
    private var cancellables = Set<AnyCancellable>()

    init(onDelete: @escaping (ItemType) -> Void = {_ in},
         onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveItem: ItemType?,
            _ belowItem: ItemType?
         ) -> Void = { _, _, _ in },
         onItemDroppedOnOtherItem: @escaping (
            _ draggedItem: ItemType,
            _ targetItem: ItemType
         ) -> Void = { _, _ in },
         hoverColor: Color = .blue) {
        
        self.onDelete = onDelete
        self.onItemDroppedOnSeparator = onItemDroppedOnSeparator
        self.onItemDroppedOnOtherItem = onItemDroppedOnOtherItem
        self.hoverColor = hoverColor
    }
    
    func updateItemsInList() {
        itemsInList.removeAll()
        
        func traverse(items: [ItemType], path: ItemPath = []) {
            for (index, item) in items.enumerated() {
                let currentPath = path + [index]
                itemsInList[currentPath] = item
                
                if let itemWithChildren = item as? any DDHItem {
                    traverse(items: itemWithChildren.children as! [ItemType], path: currentPath)
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
    }
    
    func resetRowSwiping() {
        currentlySwipedRowPath = []
    }
    
    func onDrag(_ item: ItemType) {
        if item == lastDroppedItem {
            draggedItem = nil
            lastDroppedItem = nil
        } else {
            draggedItem = item
        }

        resetTargets()
        resetRowSwiping()
    }
    
    func onDrop(_ droppedItem: ItemType) {
        if let targetItem, isDropOnItemEnabled, targetItem != droppedItem {
            onItemDroppedOnOtherItem(droppedItem, targetItem)
        } else if isDropOnSeparatorEnabled {
            let aboveItem = aboveDropTargetPath.flatMap { itemsInList[$0] }
            let belowItem = belowDropTargetPath.flatMap { itemsInList[$0] }
            
            if aboveItem != nil || belowItem != nil {
                onItemDroppedOnSeparator(droppedItem, aboveItem, belowItem)
            }
        }
        
        lastDroppedItem = droppedItem
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
