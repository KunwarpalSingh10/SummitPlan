//
//  InfoPopup.swift
//  goal app
//
//  Created by Kunwar Singh on 1/12/25.
//

import SwiftUI

struct InfoPopup: View {
    var body: some View {
        VStack(spacing: .zero) {
            icon
            title
            content
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .multilineTextAlignment(.center)
        .background(background)
        .overlay(alignment: .topTrailing) {
            close
        }
    }
}


final class SheetManager: ObservableObject {
    enum Action {
        case na
        case present
        case dismiss
    }
    @Published private(set) var action: Action = .na

    func present() {
        guard !action.isPresented else { return }
        self.action = .present
    }

    func dismiss() {
        self.action = .dismiss
    }
}




extension SheetManager.Action {
    var isPresented: Bool { self == .present }
}

private extension InfoPopup {
    var icon: some View {
        Image(systemName: "info.circle.fill")
            .font(
                .system(size: 50, weight: .bold, design: .rounded)
            )
            .foregroundColor(.blue)
    }
    var title: some View {
        Text("Text here")
            .font(
                .system(size: 30, weight: .bold, design: .rounded)
            )
            .padding()
    }
    var content: some View {
        Text("Additional information goes here.")
            .font(.callout)
            .foregroundColor(.black.opacity(0.8))
    }
    var background: some View {
        Color.white // Customize background as needed
            .cornerRadius(10)
            .shadow(radius: 5)
    }
    var close: some View {
        Button(action: {
            // Action for close button
        }) {
            Image(systemName: "xmark")
                .font(.headline)
                .padding(10)
                .background(Circle().fill(Color.gray.opacity(0.2)))
        }
    }
}

