//
//  TrashExampleView.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 19/10/25.
//

import SwiftUI

struct DeleteExampleView: View {
    var body: some View {
        ZStack {
            Color.red
            Text("Delete")
                .foregroundStyle(.white)
        }
        .frame(width: 100)
    }
}

#Preview {
    DeleteExampleView()
}
