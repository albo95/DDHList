//
//  ConditionalDraggableModifier.swift
//  DDHList
//
//  Created by Alberto Bruno on 22/10/25.
//

import Foundation
import CoreTransferable
import SwiftUI

struct ConditionalDraggableModifier<ItemType: Transferable & Identifiable>: ViewModifier {
    let item: ItemType
    let isEnabled: Bool
    let onDrag: () -> Void
    let previewView: AnyView?
    let rowWidth: CGFloat?
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        if isEnabled {
            if previewView == nil {
                content
                    .draggable( draggableFunction())
            } else {
                content
                    .draggable( draggableFunction(),
                                preview: {
                        if let previewView = previewView {
                            ZStack {
                                Rectangle()
                                    .frame(width: rowWidth)
                                    .foregroundStyle(.customInvertedPrimary)
                                    .scaleEffect(6)
                                
                                previewView
                            }
                        }
                    })
            }
        } else {
            content
        }
    }
    
    private func draggableFunction() -> ItemType {
        onDrag()
        return item
    }
}

extension View {
    func conditionalDraggable<ItemType: Transferable & Identifiable>(
        _ item: ItemType,
        isEnabled: Bool,
        onDrag: @escaping () -> Void,
        previewView: AnyView? = nil,
        rowWidth: CGFloat? = nil
    ) -> some View {
        modifier(ConditionalDraggableModifier(
            item: item,
            isEnabled: isEnabled,
            onDrag: onDrag,
            previewView: previewView,
            rowWidth: rowWidth
        ))
    }
}
