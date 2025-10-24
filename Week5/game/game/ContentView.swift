//
//  ContentView.swift
//  game
//
//  Created by 孙语鸿 on 10/10/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        ZStack {
            gameViewControllerContainer() 
                .ignoresSafeArea()
        }
    }
}

struct gameViewControllerContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> gameViewController {
        gameViewController()
    }
    func updateUIViewController(_ uiViewController: gameViewController, context: Context) {
    }
}

#Preview {
    ContentView()
}
