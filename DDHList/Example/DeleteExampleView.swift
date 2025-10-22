//
//  TrashExampleView.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 19/10/25.
//

import SwiftUI

struct DeleteExampleView: View {
    var body: some View {
        HStack {
            Text("Delete")
                .foregroundStyle(.white)
                .padding(.horizontal)
            
            Rectangle()
                .foregroundStyle(.red)
                .frame(width: 60)
        }
        .background(.red)
        .offset(x: 80)
    }
}

#Preview {
    DeleteExampleView()
}
