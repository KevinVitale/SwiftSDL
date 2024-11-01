import SwiftUI

struct ContentView: SwiftUI.View {
  var body: some SwiftUI.View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("SDL v\(SDL_Version())")
        .font(.system(size: 48))
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
