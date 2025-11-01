//
//  SwipeToDeleteModifier.swift
//  DDList
//
//  Created by Alberto Bruno on 22/10/25.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
public struct SwipeToDeleteModifier: ViewModifier {
    @Binding var isSwiped: Bool
    @State private var offsetX: CGFloat
    
    let onDelete: () -> Void
    let isActive: Bool
    let maxOffset: CGFloat
    let threshold: CGFloat
    let gestureSlower: CGFloat
    
    public init(
        onDelete: @escaping () -> Void,
        isActive: Bool = true,
        isSwiped: Binding<Bool>,
        maxOffset: CGFloat = 90,
        threshold: CGFloat = 20,
        gestureSlower: CGFloat = 0.1
    ) {
        self.onDelete = onDelete
        self.isActive = isActive
        self._isSwiped = isSwiped
        self.maxOffset = maxOffset
        self.offsetX = 0
        self.threshold = threshold
        self.gestureSlower = gestureSlower
    }
    
    public func body(content: Content) -> some View {
        if isActive == false {
            content
        } else {
            ZStack {
                ZStack {
                    Color.red
                    
                    HStack(spacing: 0) {
                        Spacer()
                        trashIconButtonView
                            .padding(.horizontal)
                            .padding(.horizontal)
                    }
                }
                
                ZStack {
                    Color.customInvertedPrimary
                    content
                    Rectangle().opacity(0.001)
                }
                .offset(x: offsetX)
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        if abs(value.translation.height) > abs(value.translation.width) {
                            return
                        }
                        let trashIconMovement = value.translation.width * gestureSlower
                        if trashIconMovement < 0 {
                            offsetX = max(offsetX + trashIconMovement, -maxOffset * 1.5)
                        } else {
                            offsetX = min(offsetX + trashIconMovement, 0)
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.3)) {
                            if offsetX > -threshold {
                                hideTrashIcon()
                            } else {
                                offsetX = -maxOffset
                                isSwiped = true
                            }
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
            Image(systemName: "trash.fill")
                .foregroundStyle(.white)
                .font(.system(size: 20, weight: .semibold))
                .frame(maxHeight: .infinity)
                .background(Color.red)
        }
    }
    
    private func hideTrashIcon() {
        withAnimation(.spring()) {
            offsetX = 0
            isSwiped = false
        }
    }
}

@available(iOS 16.0, *)
public extension View {
    func swipeToDelete(
        onDelete: @escaping () -> Void,
        isActive: Bool = true,
        isSwiped: Binding<Bool>
    ) -> some View {
        self.modifier(SwipeToDeleteModifier(
            onDelete: onDelete,
            isActive: isActive,
            isSwiped: isSwiped
        ))
    }
}
