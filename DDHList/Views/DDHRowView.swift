//
//  DDHRowView.swift
//  DDHList
//
//  Created by Alberto Bruno on 21/10/25.
//

import SwiftUI

struct DDHRowView<ItemType: DDHItem, Content: View>: View {
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

    var body: some View {
        //xxx
       // ZStack {
            content(item)
                .opacity(isItemDragged ? 0.2 : 1)
                .overlay {
                    hoverOverlay
                        .opacity(isItemDragged ? 0 : 1)
                }
                .background(
                    Rectangle()
                        .foregroundStyle(vm.hoverColor)
                        .opacity(isOnItemTarget ? 1 : 0)
                        .opacity((isItemDragged || !vm.isDropOnItemEnabled) ? 0 : 1)
                )
                .conditionalDraggable(item,
                                      isEnabled: vm.isDropOnItemEnabled || vm.isDropOnSeparatorEnabled,
                                      onDrag: { vm.onDrag(item) },
                                      previewView: AnyView(content(item)),)
            
           // pathsLogView
       // }
    }
    
    var hoverOverlay: some View {
        VStack(spacing: 0) {
            dropZone(height: .interRowHoverHeight, isActive: isAboveItemTarget) { value in
                vm.resetTargets()
                if value {
                    if aboveItemPath?.count == path.count {
                        vm.aboveDropTargetPath = aboveItemPath
                    }
                    vm.belowDropTargetPath = path
                }
            } onDrop: {
                if aboveItemPath?.count == path.count {
                    vm.aboveDropTargetPath = aboveItemPath
                }
                vm.belowDropTargetPath = path
                
                vm.onDrop()
            }
            .opacity(isDraggedItemAboveItem || !vm.isDropOnSeparatorEnabled ? 0 : 1)
            
            dropZone(isActive: false) { value in
                vm.resetTargets()
                if value {
                    vm.targetItem = item
                }
            } onDrop: {
                vm.targetItem = item
                vm.onDrop()
            }
            
            dropZone(height: .interRowHoverHeight, isActive: isBelowItemTarget) { value in
                if value {
                    vm.aboveDropTargetPath = path
                    vm.belowDropTargetPath = belowItemPath
                } else {
                    vm.belowDropTargetPath = nil
                }
            } onDrop: {
                vm.aboveDropTargetPath = path
                vm.belowDropTargetPath = belowItemPath
                vm.onDrop()
            }
            .opacity(isDraggedItemBelowItem || !vm.isDropOnSeparatorEnabled ? 0 : 1)
        }
    }
    
    @ViewBuilder
    func dropZone(
        height: CGFloat? = nil,
        isActive: Bool,
        onTargetChange: @escaping (Bool) -> Void,
        onDrop: @escaping () -> Void
    ) -> some View {
        Rectangle()
            .frame(height: height)
            .foregroundStyle(vm.hoverColor)
            .opacity(isActive ? 1 : 0.001)
            .dropDestination(for: ItemType.self) { draggedItem, _ in
                    onDrop()
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

#Preview {
    let viewModel = DDHListViewModel<ItemExample>(items: [ItemExample.mockItem])
    
    DDHRowView(
        content: { item in RowExampleView(item: item) },
        item: ItemExample.mockItem,
        path: [0],
        aboveItemPath: [-1],
        belowItemPath: [1]
    )
    .environmentObject(viewModel)
}
