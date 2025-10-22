//
//  DDHSeparatorView.swift
//  DDHList
//
//  Created by Alberto Bruno on 21/10/25.
//

import SwiftUI

struct DDHSeparatorView<ItemType: DDHItem>: View {
    @EnvironmentObject var vm: DDHListViewModel<ItemType>
    let aboveItemPath: ItemPath
    let belowItemPath: ItemPath
    
    var isBetweenItemAndChildren: Bool {
        aboveItemPath.count != belowItemPath.count
    }
    
    var isShowingHover: Bool {
        vm.isDropOnSeparatorEnabled && (vm.draggedItemPath != aboveItemPath && vm.draggedItemPath != belowItemPath && (vm.aboveDropTargetPath == aboveItemPath && vm.belowDropTargetPath == belowItemPath || (isBetweenItemAndChildren && vm.belowDropTargetPath == belowItemPath) || (isBetweenItemAndChildren && vm.targetItemPath != nil && vm.targetItemPath == belowItemPath)))
    }
    
    var body: some View {
        //xxx
        //ZStack {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(isShowingHover ? vm.hoverColor : Color.gray)
            .opacity(isShowingHover ? 1 : isBetweenItemAndChildren ? 0.0001 : 0.2)
            //pathsLogView
        //}
        .dropDestination(for: ItemType.self) { draggedItem, _ in
            vm.aboveDropTargetPath = aboveItemPath
            vm.belowDropTargetPath = belowItemPath
            vm.onDrop()
            return true
        } isTargeted: { value in
            vm.resetTargets()
            if value {
                if !isBetweenItemAndChildren {
                    vm.aboveDropTargetPath = aboveItemPath
                    vm.belowDropTargetPath = belowItemPath
                }
            }
        }
    }
    
    private var pathsLogView: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(vm.hoverColor)
                .opacity(isShowingHover ? 1 : 0.001)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                Text("\(aboveItemPath)")
                    .font(.caption)
                Text("\(belowItemPath)")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

