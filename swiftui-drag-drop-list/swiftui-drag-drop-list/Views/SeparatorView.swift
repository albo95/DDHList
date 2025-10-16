//
//  SeparatorView.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 16/10/25.
//

import Foundation
import SwiftUI

struct SeparatorView: View {
    let isTargeted: Bool
    let isHidden: Bool
    let colorOnHover: Color
    
    init(isTargeted: Bool, isHidden: Bool = false, colorOnHover: Color = .blue) {
        self.isTargeted = isTargeted
        self.isHidden = isHidden
        self.colorOnHover = colorOnHover
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .frame(height: 16)
                .foregroundStyle(colorOnHover.opacity(isTargeted ? 1 : 0.0001))
            
            Rectangle()
                .frame(height: .separatorHeight)
                .foregroundColor(Color.gray)
                .opacity(0.2)
                .padding(.leading, 50)
                .opacity(isHidden ? 0.0001 : 1)
        }
    }
}
