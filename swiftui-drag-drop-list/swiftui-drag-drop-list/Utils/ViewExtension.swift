//
//  ViewExtension.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 15/10/25.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

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
    
    @ViewBuilder
    func conditionalReadSize(_ condition: Bool, _ onChange: @escaping (CGSize) -> Void) -> some View {
        if condition {
            self.readSize(onChange)
        } else {
            self
        }
    }
    
    func readSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
        self.modifier(SizeReader(onChange: onChange))
    }
    
    @ViewBuilder
    func conditionalHeight(_ condition: Bool, _ height: CGFloat) -> some View {
        if condition {
            self.frame(height: height)
        } else {
            self
        }
    }
}

