//
//  timeApp.swift
//  time
//
//  Created by 孙语鸿 on 10/3/25.
//

import SwiftUI

@main
struct timeApp: App {
    @StateObject var data = TimeData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(data)
        }
    }
}

