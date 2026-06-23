import SwiftUI

@Observable
final class AppSettings: @unchecked Sendable {
  static let shared = AppSettings()

  var confidenceThreshold: Double {
    didSet { UserDefaults.standard.set(confidenceThreshold, forKey: "confidence_threshold") }
  }
  var saveHistoryImages: Bool {
    didSet { UserDefaults.standard.set(saveHistoryImages, forKey: "save_history_images") }
  }
  var showAllResults: Bool {
    didSet { UserDefaults.standard.set(showAllResults, forKey: "show_all_results") }
  }
  var hapticFeedback: Bool {
    didSet { UserDefaults.standard.set(hapticFeedback, forKey: "haptic_feedback") }
  }

  private init() {
    let ud = UserDefaults.standard
    self.confidenceThreshold = ud.object(forKey: "confidence_threshold") as? Double ?? 0.5
    self.saveHistoryImages = ud.object(forKey: "save_history_images") as? Bool ?? true
    self.showAllResults = ud.object(forKey: "show_all_results") as? Bool ?? true
    self.hapticFeedback = ud.object(forKey: "haptic_feedback") as? Bool ?? true
  }
}
