//
//  ViewModifier.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 15/10/25.
//

import Foundation
import SwiftUI
import CoreTransferable

struct SwipeToDeleteModifier: ViewModifier {
    let onDelete: () -> Void
    let isActive: Bool
    @Binding var isSwiped: Bool
    
    let maxOffset: CGFloat = 60
    let threshold: CGFloat = 20
    let gestureSlower: CGFloat = 0.1
    
    @State private var offsetX: CGFloat
    
    init(onDelete: @escaping () -> Void, isActive: Bool = true, isSwiped: Binding<Bool>) {
        self.onDelete = onDelete
        self.offsetX = 60
        self.isActive = isActive
        self._isSwiped = isSwiped
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            Rectangle().opacity(0.001)
            
            HStack {
                Spacer()
                trashIconButtonView
                    .offset(x: offsetX)
                    .opacity(CGFloat(1 - (offsetX / maxOffset)))
            }
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    guard isActive else { return }
                    if abs(value.translation.height) > abs(value.translation.width) {
                        return
                    }
                    
                    let trashIconMovement = value.translation.width * gestureSlower
                    if trashIconMovement > 0 {
                        offsetX = min(offsetX + trashIconMovement, maxOffset)
                    } else {
                        offsetX = max(offsetX + trashIconMovement, 0 - maxOffset/2)
                    }
                }
                .onEnded { _ in
                    if offsetX < threshold {
                        showTrashIcon()
                    } else {
                        hideTrashIcon()
                    }
                }
        )
        .onChange(of: isSwiped) { newValue in
            if !newValue {
                hideTrashIcon()
            }
        }
    }
    
    private var trashIconButtonView: some View {
        Button {
            onDelete()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hideTrashIcon()
            }
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .foregroundStyle(.red)
                .padding(.horizontal)
        }
    }
    
    private func hideTrashIcon() {
        withAnimation(.spring()) {
            offsetX = maxOffset
            isSwiped = false
        }
    }
    
    private func showTrashIcon() {
        withAnimation(.spring()) {
            offsetX = 0
            isSwiped = true
        }
    }
}

struct ConditionalDraggableModifier<ItemType: Transferable & Identifiable>: ViewModifier {
    let item: ItemType
    let isEnabled: Bool
    let onDrag: () -> Void
    let onDrop: () -> Void
    @Binding var currentlyDraggedItem: ItemType?
    @Binding var lastDraggedItem: ItemType?
    let previewView: AnyView?
    let rowWidth: CGFloat?

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if isEnabled {
            if previewView == nil {
                content
                    .draggable(
                        {
                            currentlyDraggedItem = item
                            defer {
                                onDrag()
                                if lastDraggedItem?.id == item.id {
                                    onDrop()
                                    lastDraggedItem = nil
                                }
                            }
                            return item
                        }())
            } else {
                content
                    .draggable(
                        {
                            currentlyDraggedItem = item
                            defer {
                                onDrag()
                                if lastDraggedItem?.id == item.id {
                                    onDrop()
                                    lastDraggedItem = nil
                                }
                            }
                            return item
                        }(),
                        preview: {
                            if let previewView = previewView {
                                ZStack {
                                    Rectangle()
                                        .frame(width: rowWidth)
                                        .foregroundStyle(.customInvertedPrimary)
                                    
                                    previewView
                                }
                            }
                        }
                    )
            }
        } else {
            content
        }
    }
}

extension View {
    func conditionalDraggable<ItemType: Transferable & Identifiable>(
        _ item: ItemType,
        isEnabled: Bool,
        currentlyDraggedItem: Binding<ItemType?>,
        lastDraggedItem: Binding<ItemType?>,
        onDrag: @escaping () -> Void,
        onDrop: @escaping () -> Void,
        previewView: AnyView? = nil,
        rowWidth: CGFloat? = nil
    ) -> some View {
        modifier(ConditionalDraggableModifier(
            item: item,
            isEnabled: isEnabled,
            onDrag: onDrag,
            onDrop: onDrop,
            currentlyDraggedItem: currentlyDraggedItem,
            lastDraggedItem: lastDraggedItem,
            previewView: previewView,
            rowWidth: rowWidth
        ))
    }
}

struct SizeReader: ViewModifier {
    var onChange: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            onChange(geo.size)
                        }
                        .onChange(of: geo.size) { newSize in
                            onChange(newSize)
                        }
                }
            )
    }
}
