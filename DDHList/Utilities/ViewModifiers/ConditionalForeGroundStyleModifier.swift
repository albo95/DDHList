//
//  ConditionalForeGroundStyleModifier.swift
//  DDHList
//
//  Created by Alberto Bruno on 21/10/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func conditionalForegroundStyle<S: ShapeStyle>(_ style: S, when condition: Bool) -> some View {
        if condition {
            self.foregroundStyle(style)
        } else {
            self
        }
    }
}
