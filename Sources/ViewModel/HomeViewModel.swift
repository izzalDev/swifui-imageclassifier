import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
  var croppedImage: UIImage?
  var showPicker: Bool = false
  var isAnalyzing: Bool = false
  var results: [(label: String, confidence: Float, color: Color)] = []
  var selectedEntry: HistoryEntry?

  private var historyStore = HistoryStore.shared
  private var appSettings = AppSettings.shared

  var topResult: (label: String, confidence: Float, color: Color)? {
    results.max(by: { $0.confidence < $1.confidence })
  }

  var recentEntries: [HistoryEntry] {
    Array(historyStore.entries.prefix(3))
  }

  func analyze() {
    guard let image = croppedImage else { return }
    isAnalyzing = true

    // Task inherits @MainActor; only the CPU-intensive classify is detached
    Task {
      do {
        let classResults = try await Task.detached(priority: .userInitiated) {
          try ClassifierService.shared.classify(image: image)
        }.value

        results = classResults.map { result in
          (result.label, result.confidence, Color.labelColor(for: result.label))
        }
        isAnalyzing = false

        // Save to history
        if let top = results.max(by: { $0.confidence < $1.confidence }) {
          let imageData =
            appSettings.saveHistoryImages
            ? image.jpegData(compressionQuality: 0.6)
            : nil
          let stored = classResults.map {
            StoredResult(label: $0.label, confidence: $0.confidence)
          }
          let entry = HistoryEntry(
            topLabel: top.label,
            topConfidence: top.confidence,
            results: stored,
            imageData: imageData
          )
          historyStore.add(entry)
        }

        if appSettings.hapticFeedback {
          UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
      } catch {
        print("❌ Classification error: \(error)")
        isAnalyzing = false
      }
    }
  }
}
