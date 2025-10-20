//
//  DragAndDropListView.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 16/10/25.
//

import Foundation
import SwiftUI
import CoreTransferable

struct DragAndDropListView<ItemType: Transferable & Identifiable, RowView: View>: View {
    var items: [ItemType]
    let rowView: (ItemType) -> RowView
    let isDeleteRowEnabled: Bool
    let onDelete: (Int) -> Void
    let deleteView: (() -> any View)?
    let isDragAndDropEnabled: Bool
    let onItemDroppedOnSeparator: (ItemType, Int, Int) -> Void
    let isDragAndDropOnOtherItemsEnabled: Bool
    let onItemDroppedOnOtherItem: (ItemType, ItemType) -> Void
    let colorOnHover: Color
    let separatorView: (() -> any View)?
    let belowListView: (() -> any View)?
    let isRowHeightFixed: Bool
    
    @State private var dragTargetIndex: Int? = nil
    @State private var dropTargetIndex: Int? = nil
    @State private var currentlySwipedRow: Int? = nil
    @State private var currentlyDraggedIndex: Int? = nil
    @State private var currentlyDraggedItem: ItemType? = nil
    @State private var lastDraggedItem: ItemType? = nil
    @State private var isScrollDisabled: Bool = true
    @State private var totalTranslationWidth: CGFloat = 0
    @State private var totalTranslationHeight: CGFloat = 0
    @State private var hideCurrentItem: Bool = false
    @State private var rowHeights: [Int:CGFloat]
    @State private var fixedRowHeight: CGFloat = 0
    @State private var listWidth: CGFloat = 0
    
    @Binding var isDraggingElement: Bool
    
    init(
        items: [ItemType],
        rowView: @escaping (ItemType) -> RowView,
        isDeleteRowEnabled: Bool = true,
        onDelete: @escaping (Int) -> Void = { _ in },
        deleteView: (() -> any View)? = nil,
        isDragAndDropEnabled: Bool = true,
        onItemDroppedOnSeparator: @escaping (
            _ draggedItem: ItemType,
            _ aboveIndex: Int,
            _ belowIndex: Int
        ) -> Void = { _, _, _ in },
        isDragAndDropOnOtherItemsEnabled: Bool = true,
        onItemDroppedOnOtherItem: @escaping (
            _ draggedItem: ItemType,
            _ targetItem: ItemType
        ) -> Void = { _, _ in },
        colorOnHover: Color = .blue,
        separatorView: (() -> any View)? = nil,
        belowListView: (() -> any View)? = nil,
        isDraggingElement: Binding<Bool> = .constant(false),
        isRowHeightFixed: Bool = false
    ) {
        self.items = items
        self.rowView = rowView
        self.isDeleteRowEnabled = isDeleteRowEnabled
        self.onDelete = onDelete
        self.deleteView = deleteView
        self.isDragAndDropEnabled = isDragAndDropEnabled
        self.onItemDroppedOnSeparator = onItemDroppedOnSeparator
        self.isDragAndDropOnOtherItemsEnabled = isDragAndDropOnOtherItemsEnabled
        self.onItemDroppedOnOtherItem = onItemDroppedOnOtherItem
        self.colorOnHover = colorOnHover
        self.rowHeights = [:]
        self.separatorView = separatorView
        self.belowListView = belowListView
        self._isDraggingElement = isDraggingElement
        self.isRowHeightFixed = isRowHeightFixed
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                LazyVStack(spacing: .separatorHeight) {
                    Spacer()
                        .frame(height:  .separatorHooverHeight)
                    
                    rowWrapper(for: items[0], index: 0)
                        .readSize { size in
                            rowHeights[0] = size.height
                            fixedRowHeight = size.height
                        }
                    
                    ForEach(items.dropFirst().indices, id: \.self) { index in
                        rowWrapper(for: items[index], index: index)
                            .conditionalReadSize(!isRowHeightFixed) { size in
                                rowHeights[index] = size.height
                            }
                            .conditionalHeight(isRowHeightFixed, fixedRowHeight)
                    }
                    .readSize { size in
                        listWidth = size.width
                    }
                    
                    belowListView.map { AnyView($0()) }
                    
                }
                
                
                GeometryReader { proxy in
                    separatorView(index: -1)
                        .frame(maxWidth: .infinity)
                        .position(x: proxy.size.width / 2, y: .separatorHooverHeight)
                    
                    ForEach(items.indices, id: \.self) { index in
                        let fixedIncrement = (rowHeight(for: 0)) + CGFloat.separatorHooverHeight
                        let yPos = (0..<index).reduce(CGFloat(0)) { $0 + rowHeight(for: $1) + CGFloat.separatorHeight } + fixedIncrement
                        separatorView(index: index)
                            .frame(maxWidth: .infinity)
                            .position(x: proxy.size.width / 2, y: yPos)
                    }
                }
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
    
    private func onDrag(index: Int) {
        resetSwiping()
        currentlyDraggedIndex = index
        isDraggingElement = true
    }
    
    private func resetSwiping() {
        currentlySwipedRow = nil
    }
    
    private func resetDragging() {
        dropTargetIndex = nil
        currentlyDraggedIndex = nil
        currentlyDraggedItem = nil
        hideCurrentItem = false
        isDraggingElement = false
    }
    
    // MARK: - Row Wrapper
    private func rowWrapper(for item: ItemType, index: Int) -> some View {
        DragAndDropListRowWrapper(
            index: index,
            item: item,
            currentlySwipedRow: $currentlySwipedRow,
            currentlyDraggedItem: $currentlyDraggedItem,
            lastDraggedItem: $lastDraggedItem,
            hideCurrentItem: $hideCurrentItem,
            isDeletionEnable: isDeleteRowEnabled,
            onDelete: { onDelete(index) },
            deleteView: deleteView.map { AnyView($0()) },
            content: rowView,
            onItemDroppedOnOtherItem: onItemDroppedOnOtherItem,
            colorOnHover: colorOnHover,
            onDrag: {
                onDrag(index: index)
            },
            onDrop: resetDragging,
            canBeDraggedOn: isDragAndDropOnOtherItemsEnabled,
            isDragAndDropEnabled: isDragAndDropEnabled,
            rowWidth: listWidth
        )
    }
    
    // MARK: - Separator View
    private func separatorView(index: Int)-> some View {
        DragAndDropListSeparatorView(isTargeted: dropTargetIndex == index, isHidden: false, separatorView: separatorView.map { AnyView($0()) })
            .dropDestination(for: ItemType.self) { draggedItem, location in
                defer {
                    resetDragging()
                }
                lastDraggedItem = draggedItem.first
                
                let above = index
                let below = index + 1 < items.count ? index + 1 : index
                if let firstDraggedItem = draggedItem.first {
                    onItemDroppedOnSeparator(firstDraggedItem, above, below)
                }
                return true
            } isTargeted: { value in
                hideCurrentItem = true
                guard currentlyDraggedIndex != index, currentlyDraggedIndex != index + 1 else { return }
                dropTargetIndex = value ? index : nil
            }
    }
    
    private func rowHeight(for index: Int) -> CGFloat {
        isRowHeightFixed ? fixedRowHeight : (rowHeights[index] ?? 0)
    }
}
