//
//  ContainerViewExample.swift
//  DDHList
//
//  Created by Alberto Bruno on 24/10/25.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
public struct DDListContainerView: View {
    
    public init() {}
    
    public var body: some View {
        TabView {
            DDListExamplePickerView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("DDList")
                }

            DDHListExamplePickerView()
                .tabItem {
                    Image(systemName: "list.bullet.indent")
                    Text("DDHList")
                }
        }
    }
}
