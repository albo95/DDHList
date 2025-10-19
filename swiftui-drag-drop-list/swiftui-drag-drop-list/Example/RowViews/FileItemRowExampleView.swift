//
//  FileItemRow.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 15/10/25.
//

import SwiftUI

struct FileItemRowExampleView: View {
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
    FileItemRowExampleView(fileItem: FileItemExample.mockItem)
}
