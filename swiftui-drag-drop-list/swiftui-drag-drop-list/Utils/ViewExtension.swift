//
//  ViewExtension.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 15/10/25.
//

import Foundation
import SwiftUI

extension View {
    func swipeToDelete(onDelete: @escaping () -> Void, isActive: Bool = true, isSwiped: Binding<Bool>) -> some View {
        self.modifier(SwipeToDeleteModifier(onDelete: onDelete, isActive: isActive, isSwiped: isSwiped))
    }
}
