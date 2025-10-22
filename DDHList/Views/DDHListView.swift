//
//  DDHListView.swift
//  DDHList
//
//  Created by Alberto Bruno on 21/10/25.
//

import SwiftUI

struct DDHListView<ItemType: DDHItem, RowContent: View>: View {
    @StateObject private var vm: DDHListViewModel<ItemType>

    let rowView: (ItemType) -> RowContent
    let deleteView: (() -> any View)?
    let belowListView: (() -> any View)?
    
    @State private var isScrollDisabled: Bool = true
    @State private var totalTranslationWidth: CGFloat = 0
    @State private var totalTranslationHeight: CGFloat = 0
    
    init(items: [ItemType],
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
         deleteView: (() -> any View)? = nil,
         isDeletionEnabled: Bool = true,
         isDropOnSeparatorEnabled: Bool = true,
         isDropOnItemEnabled: Bool = true,
         hoverColor: Color = .blue) {
        _vm = StateObject(wrappedValue: DDHListViewModel(items: items,
                                                         onDelete: onDelete,
                                                         onItemDroppedOnSeparator: onItemDroppedOnSeparator,
                                                         onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
                                                         isDropOnSeparatorEnabled: isDropOnSeparatorEnabled,
                                                         isDropOnItemEnabled: isDropOnItemEnabled,
                                                         isDeletionEnabled: isDeletionEnabled,
                                                         hoverColor: hoverColor))
        self.rowView = rowView
        self.belowListView = belowListView
        self.deleteView = deleteView
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hierarchicalListSection(recursiveItems: vm.items, path: [0], prevAboveItemPath: nil)
                
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
                isScrollDisabled = false
                totalTranslationWidth = 0
                totalTranslationHeight = 0
            })

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
            
            if vm.expandedItemsIDs.contains(item.id) {
                AnyView(hierarchicalListSection(recursiveItems: item.children, path: currentPath + [0], prevAboveItemPath: currentPath))
                    .padding(.leading, 40)
            }
        }
    }
    
    @ViewBuilder
    private func hierarchicalRowView(item: ItemType, itemPath: ItemPath, aboveItemPath: ItemPath, belowItemPath: ItemPath, index: Int) -> some View {

        HStack(alignment: .center, spacing: 0) {
            expandButtonView(item: item)
            
            VStack(spacing: 0) {
//                if index == 0 {
//                    DDHSeparatorView<ItemType>(
//                        aboveItemPath: aboveItemPath,
//                        belowItemPath: itemPath
//                    )
//                }
                
                DDHRowView<ItemType, RowContent>(
                    content: { rowView($0) },
                    item: item,
                    path: itemPath,
                    aboveItemPath: aboveItemPath,
                    belowItemPath: belowItemPath
                )
                .swipeToDelete(onDelete: { vm.onDelete(item) },
                               isActive: vm.isDeletionEnabled,
                               deleteView: deleteView.map { AnyView($0()) },
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
                    belowItemPath: belowItemPath
                )
            }
        }
    }
    
    
    @ViewBuilder
    private func expandButtonView(item: ItemType) -> some View {
        Button(action: {
            withAnimation {
                vm.toggleElementExpanded(itemID: item.id)
            }
        }, label: {
            Image(systemName: "chevron.down")
                .rotationEffect(Angle(degrees:
                                        vm.expandedItemsIDs.contains(item.id) ? 0 : -90))
        })
        .opacity(item.children.isEmpty ? 0 : 1)
    }
    
    private var targetElementsLogView: some View {
        VStack {
            Text("Targeted item: \(vm.targetItem)")
            Text("Above Drop Target Path: \(vm.aboveDropTargetPath)")
            Text("Below Drop Target Path: \(vm.belowDropTargetPath)")
        }
        .padding()
    }
}



#Preview {
    DDHListView<ItemExample, RowExampleView>(
        items: ItemExample.mockItems,
        rowView: { item in RowExampleView(item: item) }
    )
}
