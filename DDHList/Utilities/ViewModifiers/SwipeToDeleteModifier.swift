//
//  SwipeToDeleteModifier.swift
//  DDHList
//
//  Created by Alberto Bruno on 22/10/25.
//

import Foundation
import SwiftUI

struct SwipeToDeleteModifier: ViewModifier {
    let onDelete: () -> Void
    let isActive: Bool
    let deleteView: AnyView?
    let maxOffset: CGFloat = 60
    let threshold: CGFloat = 20
    let gestureSlower: CGFloat = 0.1
    
    @Binding var isSwiped: Bool
    
    @State private var offsetX: CGFloat
    
    init(onDelete: @escaping () -> Void, isActive: Bool = true, isSwiped: Binding<Bool>, deleteView: AnyView? = nil) {
        self.onDelete = onDelete
        self.offsetX = 60
        self.isActive = isActive
        self.deleteView = deleteView
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
            if let deleteView {
                deleteView
            } else {
                HStack {
                    Text("Delete")
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    Rectangle()
                        .foregroundStyle(.red)
                        .frame(width: 60)
                }
                .background(.red)
                .offset(x: 80)
            }
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
extension View {
    func swipeToDelete(
        onDelete: @escaping () -> Void,
        isActive: Bool = true,
        deleteView: AnyView? = nil,
        isSwiped: Binding<Bool>
    ) -> some View {
        self.modifier(SwipeToDeleteModifier(
            onDelete: onDelete,
            isActive: isActive,
            isSwiped: isSwiped,
            deleteView: deleteView
        ))
    }
}
