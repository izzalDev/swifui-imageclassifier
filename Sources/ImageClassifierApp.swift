import SwiftUI

#if DEBUG
  @_exported import HotSwiftUI
#endif

@main
struct YourAppApp: App {
  init() {
    #if DEBUG
      setenv("INJECTION_DIRECTORIES", "/Users/izzal/Repositories/ImageClassifier", 1)
    #endif
  }

  var body: some Scene {
    WindowGroup {
      HomeView()
    }
  }
}
