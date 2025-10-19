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
    let showJustTopHalf: Bool
    let showJustBottomHalf: Bool
    
    init(isTargeted: Bool, isHidden: Bool = false, showJustTopHalf: Bool = false, showJustBottomHalf: Bool = false, colorOnHover: Color = .blue) {
        self.isTargeted = isTargeted
        self.isHidden = isHidden
        self.colorOnHover = colorOnHover
        self.showJustTopHalf = showJustTopHalf
        self.showJustBottomHalf = showJustBottomHalf
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: .separatorHeight)
                .foregroundColor(.separatorGray)
                .opacity(isHidden ? 0.0001 : 1)
            
            RoundedRectangle(cornerRadius: 12)
                .frame(height: 16)
                .foregroundStyle(colorOnHover.opacity(isTargeted ? 1 : 0.0001))
                .mask(
                    GeometryReader { geo in
                        Rectangle()
                            .frame(
                                height: showJustTopHalf ? geo.size.height / 2 :
                                    showJustBottomHalf ? geo.size.height / 2 :
                                    geo.size.height
                            )
                            .offset(
                                y: showJustBottomHalf ? geo.size.height / 2 : 0
                            )
                    }
                )
        }
    }
}
