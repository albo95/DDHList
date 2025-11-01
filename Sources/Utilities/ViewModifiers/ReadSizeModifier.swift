//
//  File.swift
//  DDHList
//
//  Created by Alberto Bruno on 01/11/25.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
extension View {
    func readSize(_ onChange: @escaping (CGSize) -> Void = {_ in}, onAppear: ((CGSize) -> Void)? = nil, onlyOnAppear: Bool = false) -> some View {
        self.modifier(SizeReaderModifier(onAppear: onAppear, onChange: onChange, onlyOnAppear: onlyOnAppear))
    }
}

@available(iOS 16.0, *)
struct SizeReaderModifier: ViewModifier {
    let onAppear: ((CGSize) -> Void)?
    let onChange: (CGSize) -> Void
    let onlyOnAppear: Bool
    
    init(onAppear: ( (CGSize) -> Void )? = nil, onChange: @escaping (CGSize) -> Void = {_ in}, onlyOnAppear: Bool = false) {
        self.onAppear = onAppear
        self.onChange = onChange
        self.onlyOnAppear = onlyOnAppear
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            let size = geo.size
                            if let onAppear {
                                onAppear(size)
                            } else {
                                onChange(size)
                            }
                        }
                        .onChange(of: geo.size) { value in
                            if !onlyOnAppear {
                                onChange(value)
                            }
                        }
                }
            )
    }
}
