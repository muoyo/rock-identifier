//
//  InteractiveDismissModifier.swift
//  RockIdentifier
//

import SwiftUICore

struct InteractiveDismissModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.interactiveDismissDisabled(isEnabled)
        } else {
            content
        }
    }
}
