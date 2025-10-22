//
//  RowExampleView.swift
//  DDHList
//
//  Created by Alberto Bruno on 21/10/25.
//

import SwiftUI

struct RowExampleView: View {
    let item: ItemExample
    
    var body: some View {
        HStack {
            Text(item.name)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    RowExampleView(item: ItemExample.mockItem)
}
