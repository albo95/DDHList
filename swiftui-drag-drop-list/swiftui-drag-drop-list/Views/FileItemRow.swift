//
//  FileItemRow.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 15/10/25.
//

import SwiftUI

struct FileItemRow: View {
    let fileItem: FileItem
    var body: some View {
        HStack {
            Text(fileItem.name)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    FileItemRow(fileItem: FileItem.mockItem)
}
