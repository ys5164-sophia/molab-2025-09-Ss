
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
