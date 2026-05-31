import SwiftUI

#if DEBUG
  @_exported import HotSwiftUI
#endif

@main
struct YourAppApp: App {
  init() {
    #if DEBUG
      Bundle(path: "/Applications/InjectionNext.app/Contents/Resources/iOSInjection.bundle")?.load()
    #endif
  }

  var body: some Scene {
    WindowGroup {
      HomeView()
    }
  }
}
