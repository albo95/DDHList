//
//  ProveDragAndDropSezioniApp.swift
//  ProveDragAndDropSezioni
//
//  Created by Alberto Bruno on 15/10/25.
//

import SwiftUI

@main
struct ProveDragAndDropSezioniApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DragDropListExampleView()
                .tabItem {
                    Label("Simple", systemImage: "list.bullet")
                }

            HierarchicalDragDropListExampleView()
                .tabItem {
                    Label("Hierarchical", systemImage: "list.triangle")
                }
        }
    }
}
