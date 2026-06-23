import SwiftUI

@Observable
final class SettingsViewModel {
  var settings = AppSettings.shared
  var store = HistoryStore.shared

  var showClearHistoryConfirm: Bool = false
  var showAbout: Bool = false

  var historyCount: Int {
    store.entries.count
  }

  var isHistoryEmpty: Bool {
    store.entries.isEmpty
  }

  var appVersion: String {
    let version =
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "\(version) (\(build))"
  }

  func clearHistory() {
    store.deleteAll()
  }
}
