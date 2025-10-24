//
//  RowExampleView.swift
//  DDList
//
//  Created by Alberto Bruno on 21/10/25.
//

import SwiftUI

@available(iOS 16.0, *)
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
