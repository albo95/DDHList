//
//  SwipeToDeleteModifier.swift
//  DDList
//
//  Created by Alberto Bruno on 22/10/25.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct SwipeToDeleteModifier: ViewModifier {
    @Binding var isSwiped: Bool
    @State private var offsetX: CGFloat
    
    let onDelete: () -> Void
    let isActive: Bool
    let deleteView: AnyView?
    let maxOffset: CGFloat
    let threshold: CGFloat
    let gestureSlower: CGFloat

    init(
        onDelete: @escaping () -> Void,
        isActive: Bool = true,
        isSwiped: Binding<Bool>,
        deleteView: AnyView? = nil,
        maxOffset: CGFloat = 80,
        threshold: CGFloat = 20,
        gestureSlower: CGFloat = 0.1
    ) {
        self.onDelete = onDelete
        self.isActive = isActive
        self._isSwiped = isSwiped
        self.deleteView = deleteView
        self.maxOffset = maxOffset
        self.offsetX = maxOffset
        self.threshold = threshold
        self.gestureSlower = gestureSlower
    }
    
    func body(content: Content) -> some View {
        if isActive == false {
            content
        } else {
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
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
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
                        .frame(width: maxOffset)
                }
                .background(.red)
                .offset(x: maxOffset)
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

@available(iOS 16.0, *)
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
