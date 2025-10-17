//
//  HierarchicalFileItemRowExample.swift
//  swiftui-drag-drop-list
//
//  Created by Alberto Bruno on 17/10/25.
//

import SwiftUI

struct HierarchicalFileItemRowExample: View {
    let hierarchicalFileItem: HierarchicalFileItemExample
    var body: some View {
        HStack {
            Text(hierarchicalFileItem.name)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    HierarchicalFileItemRowExample(hierarchicalFileItem: HierarchicalFileItemExample.mockItem)
}
