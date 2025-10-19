//
//  SeparatorView.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 16/10/25.
//

import Foundation
import SwiftUI

struct DragAndDropListSeparatorView: View {
    let isTargeted: Bool
    let isHidden: Bool
    let colorOnHover: Color
    let separatorView: AnyView?
    
    init(isTargeted: Bool, isHidden: Bool = false, colorOnHover: Color = .blue, separatorView: AnyView? = nil) {
        self.isTargeted = isTargeted
        self.isHidden = isHidden
        self.colorOnHover = colorOnHover
        self.separatorView = separatorView
    }
    
    var body: some View {
        Group {
            if let separatorView = separatorView {
                separatorView
            } else {
                Rectangle()
                    .frame(height: .separatorHeight)
                    .foregroundColor(.separatorGray)
            }
        }
        .opacity(isHidden || isTargeted ? 0.0001 : 1)
        .padding(.vertical, 8)
        .background() {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(colorOnHover.opacity(isTargeted ? 1 : 0.0001))
        }
    }
}
