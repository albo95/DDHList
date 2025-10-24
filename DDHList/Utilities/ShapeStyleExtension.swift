//
//  File.swift
//  DDList
//
//  Created by Alberto Bruno on 22/10/25.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
extension ShapeStyle where Self == Color {
    static var customInvertedPrimary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .black : .white
        })
    }
}
