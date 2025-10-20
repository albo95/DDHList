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
            
            HierarchicalDragDropListExampleView()
                .tabItem {
                    Label("Hierarchical", systemImage: "list.triangle")
                }
            
            DragDropListExampleView()
                .tabItem {
                    Label("Simple", systemImage: "list.bullet")
                }
            
        }
    }
}
