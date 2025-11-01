//
//  DDListView.swift
//  DDList
//
//  Created by Alberto Bruno on 21/10/25.
//

import SwiftUI

@available(iOS 16.0, *)
public struct DDListView<ItemType: Transferable & Identifiable & Equatable, RowContent: View>: View {
    @StateObject private var vm: DDHListViewModel<ItemType>
    @Binding var items: [ItemType]
    @Binding var isDeletionEnabled: Bool
    @Binding var isDropOnSeparatorEnabled: Bool
    @Binding var isDropOnItemEnabled: Bool
    
    let rowView: (ItemType) -> RowContent
    let belowListView: (() -> any View)?
    let rowBackgroundView: (() -> any View)?
    let listBackgroundView: (() -> any View)?
    
    @State private var isScrollDisabled: Bool = false
    @State private var totalTranslationWidth: CGFloat = 0
    @State private var totalTranslationHeight: CGFloat = 0
    
    public init(items: Binding<[ItemType]>,
                rowView: @escaping (ItemType) -> RowContent,
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
                belowListView: (() -> any View)? = nil,
                rowBackgroundView: (() -> any View)? = nil,
                listBackgroundView: (() -> any View)? = nil,
                hoverColor: Color = .blue,
                isDeletionEnabled: Binding<Bool> = .constant(true),
                isDropOnSeparatorEnabled: Binding<Bool> = .constant(true),
                isDropOnItemEnabled: Binding<Bool> = .constant(true)) {
        self.rowView = rowView
        self.belowListView = belowListView
        self.rowBackgroundView = rowBackgroundView
        self.listBackgroundView = listBackgroundView
        self._items = items
        self._isDeletionEnabled = isDeletionEnabled
        self._isDropOnSeparatorEnabled = isDropOnSeparatorEnabled
        self._isDropOnItemEnabled = isDropOnItemEnabled
        
        _vm = StateObject(wrappedValue: DDHListViewModel(
            onDelete: onDelete,
            onItemDroppedOnSeparator: onItemDroppedOnSeparator,
            onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
            hoverColor: hoverColor
        ))
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    listBackgroundView.map { AnyView($0()) }.allowsHitTesting(false)
                    
                    VStack(spacing: 0) {
                        hierarchicalListSection(recursiveItems: items, path: [0], prevAboveItemPath: nil)
                    }
                }
                
                belowListView.map { AnyView($0()) }
            }
            .environmentObject(vm)
        }
        .scrollDisabled(isScrollDisabled)
        .simultaneousGesture(DragGesture().onChanged { gesture in
            totalTranslationWidth += abs(gesture.translation.width)
            totalTranslationHeight += abs(gesture.translation.height)
            isScrollDisabled = totalTranslationWidth > totalTranslationHeight
        }
            .onEnded {_ in
                if vm.draggedItem != nil {
                    vm.draggedItem = nil
                }
                isScrollDisabled = false
                totalTranslationWidth = 0
                totalTranslationHeight = 0
            })
        .onAppear() {
            vm.items = items
            vm.isDeletionEnabled = isDeletionEnabled
            vm.isDropOnSeparatorEnabled = isDropOnSeparatorEnabled
            vm.isDropOnItemEnabled = isDropOnItemEnabled
        }
        .onChange(of: items) { newValue in
            vm.items = newValue
        }
        .onChange(of: isDeletionEnabled) { newValue in
            vm.isDeletionEnabled = newValue
        }
        .onChange(of: isDropOnSeparatorEnabled) { newValue in
            vm.isDropOnSeparatorEnabled = newValue
        }
        .onChange(of: isDropOnItemEnabled) { newValue in
            vm.isDropOnItemEnabled = newValue
        }
        //targetElementsLogView
    }
    
    @ViewBuilder
    private func hierarchicalListSection(recursiveItems: [ItemType], path: ItemPath, prevAboveItemPath: ItemPath?) -> some View {
        
        ForEach(recursiveItems.indices, id: \.self) { index in
            let item = recursiveItems[index]
            let currentPath: ItemPath = path.withLast(index)
            let aboveItemPath: ItemPath = (index == 0 ? prevAboveItemPath : nil) ?? path.withLast(index - 1)
            let belowItemPath: ItemPath = path.withLast(index + 1)
            
            hierarchicalRowView(item: item, itemPath: currentPath, aboveItemPath: aboveItemPath, belowItemPath: belowItemPath, index: index)
        }
    }
    
    @ViewBuilder
    private func hierarchicalRowView(item: ItemType, itemPath: ItemPath, aboveItemPath: ItemPath, belowItemPath: ItemPath, index: Int) -> some View {
        ZStack {
            rowBackgroundView.map { AnyView($0()) }.allowsHitTesting(false)
            
            VStack(spacing: 0) {
                DDRowView<ItemType, RowContent>(
                    content: { rowView($0) },
                    item: item,
                    path: itemPath,
                    aboveItemPath: aboveItemPath,
                    belowItemPath: belowItemPath
                )
                .swipeToDelete(onDelete: { vm.onDelete(item) },
                               isActive: vm.isDeletionEnabled,
                               isSwiped: Binding(
                                get: { vm.currentlySwipedRowPath == itemPath },
                                set: { newValue in
                                    if newValue {
                                        vm.currentlySwipedRowPath = itemPath
                                    } else if vm.currentlySwipedRowPath == itemPath {
                                        vm.resetRowSwiping()
                                    }
                                }))
                
                DDHSeparatorView<ItemType>(
                    aboveItemPath: itemPath,
                    belowItemPath: belowItemPath)
            }
        }
    }
    
    //    private var targetElementsLogView: some View {
    //        VStack {
    //            Text("Targeted item: \(vm.targetItem)")
    //            Text("Above Drop Target Path: \(vm.aboveDropTargetPath)")
    //            Text("Below Drop Target Path: \(vm.belowDropTargetPath)")
    //        }
    //        .padding()
    //    }
}
