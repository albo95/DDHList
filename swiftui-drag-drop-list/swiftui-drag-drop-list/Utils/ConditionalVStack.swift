//
//  ConditionalVStack.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 20/10/25.
//

import Foundation
import SwiftUI

@ViewBuilder
func ConditionalStack<Content: View>(
    isLazy: Bool,
    alignment: HorizontalAlignment = .leading,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
) -> some View {
    if isLazy {
        LazyVStack(alignment: alignment, spacing: spacing) {
            content()
        }
    } else {
        VStack(alignment: alignment, spacing: spacing) {
            content()
        }
    }
}
