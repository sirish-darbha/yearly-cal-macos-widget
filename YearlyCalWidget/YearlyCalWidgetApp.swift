import SwiftUI

@main
struct YearlyCalWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Yearly Calendar Widget")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Add the widget to your desktop from the widget gallery.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }
}
