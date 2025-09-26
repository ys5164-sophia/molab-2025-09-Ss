//
//  ContentView.swift
//  stimulator
//
//  Created by 孙语鸿 on 9/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var uiImage: UIImage = makeGrasslandImage(size: .init(width: 1024, height: 1024))
    
    var body: some View {
        VStack(spacing: 16) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 600, maxHeight: 600)
            
            Button("Refresh") {
                uiImage = makeGrasslandImage(size: .init(width: 1024, height: 1024))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
