import Foundation

enum ModelType: String, CaseIterable {
  case svm = "svm"
  case caeSVM = "cae_svm"

  var displayName: String {
    switch self {
    case .svm:
      return "SVM Classifier"
    case .caeSVM:
      return "CAE-SVM Classifier"
    }
  }

  var fileName: String {
    return self.rawValue
  }
}

final class AppSettings: @unchecked Sendable {
  static let shared = AppSettings()

  var confidenceThreshold: Double {
    didSet {
      UserDefaults.standard.set(confidenceThreshold, forKey: "confidence_threshold")
      notifyChange()
    }
  }

  var saveHistoryImages: Bool {
    didSet {
      UserDefaults.standard.set(saveHistoryImages, forKey: "save_history_images")
      notifyChange()
    }
  }

  var showAllResults: Bool {
    didSet {
      UserDefaults.standard.set(showAllResults, forKey: "show_all_results")
      notifyChange()
    }
  }

  var hapticFeedback: Bool {
    didSet {
      UserDefaults.standard.set(hapticFeedback, forKey: "haptic_feedback")
      notifyChange()
    }
  }

  var selectedModel: ModelType {
    didSet {
      UserDefaults.standard.set(selectedModel.rawValue, forKey: "selected_model")
      NotificationCenter.default.post(name: .modelDidChange, object: nil)
      notifyChange()
    }
  }

  private func notifyChange() {
    NotificationCenter.default.post(name: .settingsDidChange, object: nil)
  }

  private init() {
    let ud = UserDefaults.standard

    self.confidenceThreshold = ud.object(forKey: "confidence_threshold") as? Double ?? 0.5
    self.saveHistoryImages = ud.object(forKey: "save_history_images") as? Bool ?? true
    self.showAllResults = ud.object(forKey: "show_all_results") as? Bool ?? true
    self.hapticFeedback = ud.object(forKey: "haptic_feedback") as? Bool ?? true

    let savedModel = ud.string(forKey: "selected_model") ?? ModelType.caeSVM.rawValue
    self.selectedModel = ModelType(rawValue: savedModel) ?? .caeSVM
  }
}

extension Notification.Name {
  static let modelDidChange = Notification.Name("modelDidChange")
  static let settingsDidChange = Notification.Name("settingsDidChange")
}
