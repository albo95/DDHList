//
//  FileItemRow.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 15/10/25.
//

import SwiftUI

struct FileItemRowExample: View {
    let fileItem: FileItemExample
    var body: some View {
        HStack {
            Text(fileItem.name)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    FileItemRowExample(fileItem: FileItemExample.mockItem)
}
