import SwiftUI

struct HistoryEntry: Identifiable, Codable {
  let id: UUID
  let date: Date
  let topLabel: String
  let topConfidence: Float
  let results: [StoredResult]
  var imageData: Data?

  init(
    id: UUID = UUID(),
    date: Date = .now,
    topLabel: String,
    topConfidence: Float,
    results: [StoredResult],
    imageData: Data? = nil
  ) {
    self.id = id
    self.date = date
    self.topLabel = topLabel
    self.topConfidence = topConfidence
    self.results = results
    self.imageData = imageData
  }

  var image: UIImage? {
    guard let data = imageData else { return nil }
    return UIImage(data: data)
  }
}

struct StoredResult: Codable {
  let label: String
  let confidence: Float
}

@Observable
final class HistoryStore: @unchecked Sendable {
  static let shared = HistoryStore()

  var entries: [HistoryEntry] = []

  private let saveKey = "history_entries"

  private init() {
    load()
  }

  func add(_ entry: HistoryEntry) {
    entries.insert(entry, at: 0)
    save()
  }

  func delete(at offsets: IndexSet) {
    entries.remove(atOffsets: offsets)
    save()
  }

  func deleteAll() {
    entries.removeAll()
    save()
  }

  private func save() {
    if let data = try? JSONEncoder().encode(entries) {
      UserDefaults.standard.set(data, forKey: saveKey)
    }
  }

  private func load() {
    guard let data = UserDefaults.standard.data(forKey: saveKey),
      let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data)
    else { return }
    entries = decoded
  }
}
