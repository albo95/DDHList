//
//  HierarchicalRowWrapper.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 18/10/25.
//

import Foundation
import SwiftUI

struct DragAndDropHierarchicalListRowWrapper<ItemType: Transferable & Identifiable, Content: View>: View {
    let path: [Int]
    let item: ItemType
    @Binding var currentlySwipedRowPath: [Int]
    @Binding var currentlyDraggedItem: ItemType?
    @Binding var lastDraggedItem: ItemType?
    @Binding var hideCurrentItem: Bool
    let isDeletionEnable: Bool
    let deleteView: AnyView?
    let onDelete: () -> Void
    let content: (ItemType) -> Content
    let onItemDroppedOnOtherItem: (ItemType, ItemType) -> Void
    let colorOnHover: Color
    let onDrag: () -> Void
    let onDrop: () -> Void
    let canBeDraggedOn: Bool
    let isDragAndDropEnabled: Bool
    let rowWidth: CGFloat?
    @State private var isTargeted: Bool = false
    
    var body: some View {
        ZStack {
            if isTargeted {
                RoundedRectangle(cornerRadius: .separatorHooverHeight)
                    .foregroundStyle(colorOnHover)
            }
            
            content(item)
                .swipeToDelete(
                    onDelete: onDelete,
                    isActive: isDeletionEnable,
                    deleteView: deleteView,
                    isSwiped: Binding(
                        get: { currentlySwipedRowPath == path },
                        set: { newValue in
                            if newValue {
                                currentlySwipedRowPath = path
                            } else if currentlySwipedRowPath == path {
                                currentlySwipedRowPath = []
                            }
                        }
                    )
                )
                .opacity((currentlyDraggedItem?.id == item.id && hideCurrentItem) ? 0.2 : 1)
                .conditionalDraggable(
                    item,
                    isEnabled: isDragAndDropEnabled,
                    currentlyDraggedItem: $currentlyDraggedItem,
                    lastDraggedItem: $lastDraggedItem,
                    onDrag: onDrag,
                    onDrop: onDrop,
                    previewView: AnyView(content(item)),
                    rowWidth: rowWidth
                )
                .dropDestination(for: ItemType.self) { draggedItem, location in
                    defer {
                        lastDraggedItem = draggedItem.first
                        onDrop()
                    }
                    
                    guard canBeDraggedOn else { return false }
                    guard currentlyDraggedItem?.id != item.id else {
                        currentlyDraggedItem = nil
                        return false
                    }
                    
                    if let firstDraggedItem = draggedItem.first {
                        onItemDroppedOnOtherItem(firstDraggedItem, item)
                        return true
                    }
                    return false
                    
                } isTargeted: { value in
                    hideCurrentItem = true
                    guard canBeDraggedOn, currentlyDraggedItem?.id != item.id else { return }
                    isTargeted = value
                }
        }
    }
}
