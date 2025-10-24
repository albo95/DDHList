//
//  DDHRowView.swift
//  DDHList
//
//  Created by Alberto Bruno on 21/10/25.
//

import SwiftUI

@available(iOS 16.0, *)
struct DDHRowView<ItemType: Transferable & Identifiable & Equatable, Content: View>: View {
    @EnvironmentObject var vm: DDHListViewModel<ItemType>
    
    let content: (ItemType) -> Content
    let item: ItemType
    let path: ItemPath
    let aboveItemPath: ItemPath?
    let belowItemPath: ItemPath?
    
    var isItemDragged: Bool { vm.draggedItem != nil && vm.draggedItem == item }
    var isOnItemTarget: Bool { vm.targetItem != nil && vm.targetItem == item }
    
    var isAboveItemTarget: Bool { (vm.belowDropTargetPath != nil) && vm.belowDropTargetPath == path }
    var isBelowItemTarget: Bool  { (vm.aboveDropTargetPath != nil) && vm.aboveDropTargetPath == path }
    
    var isDraggedItemAboveItem: Bool { vm.draggedItemPath != nil && vm.draggedItemPath == aboveItemPath }
    var isDraggedItemBelowItem: Bool { vm.draggedItemPath != nil && vm.draggedItemPath == belowItemPath }
    
    var dropZoneAboveHeight: CGFloat {
        isShowingHalfAboveHover ? .interRowHoverHeight/2 : .interRowHoverHeight
    }
    
    var dropZoneBelowHeight: CGFloat {
        isShowingHalfBelowHover ? .interRowHoverHeight/2 : .interRowHoverHeight
    }
    
    var isShowingHalfAboveHover: Bool {
        !vm.isItemOfPathExpanded(aboveItemPath) && vm.doesItemExist(at: aboveItemPath)
    }
    
    var isShowingHalfBelowHover: Bool {
        !vm.expandedItemsIDs.contains(item.id) && vm.doesItemExist(at: belowItemPath)
    }
    
    var body: some View {
        //xxx
        // ZStack {
        content(item)
            .opacity(isItemDragged ? 0.2 : 1)
            .overlay {
                hoverOverlay
                    .opacity(isItemDragged ? 0 : 1)
                    .allowsHitTesting(vm.draggedItem != nil)
            }
            .background(
                Rectangle()
                    .foregroundStyle(vm.hoverColor)
                    .opacity(isOnItemTarget ? 1 : 0.001)
                    .opacity((isItemDragged || !vm.isDropOnItemEnabled) ? 0.001 : 1)
            )
            .conditionalDraggable(item,
                                  isEnabled: vm.isDropOnItemEnabled || vm.isDropOnSeparatorEnabled,
                                  onDrag: { vm.onDrag(item) },
                                  previewView: AnyView(content(item)),)
        
        // pathsLogView
        //  }
    }
    
    var hoverOverlay: some View {
        VStack(spacing: 0) {
            dropZone(height: dropZoneAboveHeight, isActive: isAboveItemTarget, isAbove: false) { value in
                vm.resetTargets()
                if value {
                    if aboveItemPath?.count == path.count {
                        vm.aboveDropTargetPath = aboveItemPath
                    }
                    vm.belowDropTargetPath = path
                }
            } onDrop: { droppedItem in
                if aboveItemPath?.count == path.count {
                    vm.aboveDropTargetPath = aboveItemPath
                }
                vm.belowDropTargetPath = path
                
                vm.onDrop(droppedItem)
            }
            .opacity(isDraggedItemAboveItem || !vm.isDropOnSeparatorEnabled ? 0 : 1)
            
            dropZone(isActive: false) { value in
                vm.resetTargets()
                if value {
                    vm.targetItem = item
                }
            } onDrop: { droppedItem in
                vm.targetItem = item
                vm.onDrop(droppedItem)
            }
            
            dropZone(height: dropZoneBelowHeight, isActive: isBelowItemTarget, isAbove: true) { value in
                vm.resetTargets()
                if value {
                    vm.aboveDropTargetPath = path
                    vm.belowDropTargetPath = belowItemPath
                }
            } onDrop: {
                droppedItem in
                vm.aboveDropTargetPath = path
                vm.belowDropTargetPath = belowItemPath
                vm.onDrop(droppedItem)
            }
            .opacity(isDraggedItemBelowItem || !vm.isDropOnSeparatorEnabled ? 0 : 1)
        }
    }
    
    @ViewBuilder
    func dropZone(
        height: CGFloat? = nil,
        isActive: Bool,
        isAbove: Bool = true,
        onTargetChange: @escaping (Bool) -> Void,
        onDrop: @escaping (ItemType) -> Void
    ) -> some View {
        VStack(spacing: 0) {
            if isAbove {
                Rectangle()
                    .frame(height: 10)
                    .opacity(0.001)
            }
            
            Rectangle()
                .frame(height: height)
                .foregroundStyle(vm.hoverColor)
            
            if !isAbove {
                Rectangle()
                    .frame(height: 10)
                    .opacity(0.001)
            }
            
        }
        .opacity(isActive ? 1 : 0.001)
        .dropDestination(for: ItemType.self) { droppedItems, _ in
            guard let droppedItem = droppedItems.first else { return false }
            onDrop(droppedItem)
            return true
        } isTargeted: { onTargetChange($0) }
    }
    
    private var pathsLogView: some View {
        VStack {
            if let aboveItemPath {
                Text("\(aboveItemPath)")
                    .font(.caption)
            }
            
            if let path = vm.itemsInList.first(where: { $0.value.id == item.id })?.key {
                Text("\(path)")
            }
            
            if let belowItemPath {
                Text("\(belowItemPath)")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

