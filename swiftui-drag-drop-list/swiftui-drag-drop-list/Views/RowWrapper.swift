//
//  FileItemRowWrapperGeneric.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 16/10/25.
//

import Foundation
import SwiftUI

struct RowWrapper<ItemType: Transferable & Identifiable, Content: View>: View {
    let index: Int
    let item: ItemType
    @Binding var currentlySwipedRow: Int?
    @Binding var currentlyDraggedItem: ItemType?
    @Binding var lastDraggedItem: ItemType?
    @Binding var hideCurrentItem: Bool
    let isDeletionEnable: Bool
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
                    isSwiped: Binding(
                        get: { currentlySwipedRow == index },
                        set: { newValue in
                            if newValue {
                                currentlySwipedRow = index
                            } else if currentlySwipedRow == index {
                                currentlySwipedRow = nil
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
                    
                    guard canBeDraggedOn else {
                        return false
                    }
                    
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
                    if !hideCurrentItem {
                        hideCurrentItem = true
                    }
                    guard canBeDraggedOn, currentlyDraggedItem?.id != item.id else { return }
                    isTargeted = value
                }
        }
    }
}
