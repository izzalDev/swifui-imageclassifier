import SwiftUI

#if DEBUG
  @_exported import HotSwiftUI
#endif

@main
struct YourAppApp: App {
  @ObserveInjection var injection
  init() {
    #if DEBUG
      setenv("INJECTION_DIRECTORIES", "/Users/izzal/Repositories/ImageClassifier", 1)
    #endif
  }

  var body: some Scene {
    WindowGroup {
      TabView {
        Tab("Home", systemImage: "house.fill") {
          HomeView()
        }
        Tab("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90") {
          HomeView()
        }
        Tab("Settings", systemImage: "gearshape.fill") {
          HomeView()
        }
      }
      .tint(.accent)
      .enableInjection()
    }
  }
}
