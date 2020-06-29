//
//  AdaptiveKeyboardPadding.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/25/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//
import Combine
import SwiftUI

public struct AdaptiveKeyboardPadding: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
       ).eraseToAnyPublisher()
    }

    public func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(keyboardHeightPublisher) { self.keyboardHeight = $0 }
    }
}

extension View {
    func adaptiveKeyboardPadding() -> some View {
        ModifiedContent(content: self, modifier: AdaptiveKeyboardPadding())
    }
}
