
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RecordView()
                .tabItem { Label("Record", systemImage: "square.grid.3x3") }

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar") }
        }
    }
}
