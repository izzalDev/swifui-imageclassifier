import SwiftUI

@Observable
final class HistoryViewModel {
  private var store = HistoryStore.shared

  var selectedEntry: HistoryEntry?
  var showClearConfirm: Bool = false

  var entries: [HistoryEntry] {
    store.entries
  }

  /// Entries bucketed by calendar day, ordered most-recent first.
  /// Each element is a (groupLabel, entries) tuple.
  var groupedEntries: [(label: String, entries: [HistoryEntry])] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: store.entries) { entry in
      calendar.startOfDay(for: entry.date)
    }
    return grouped
      .sorted { $0.key > $1.key }
      .map { (day, dayEntries) in
        let label: String
        if calendar.isDateInToday(day) {
          label = "Today"
        } else if calendar.isDateInYesterday(day) {
          label = "Yesterday"
        } else {
          label = day.formatted(Date.FormatStyle().weekday(.wide).month(.wide).day())
        }
        return (label, dayEntries.sorted { $0.date > $1.date })
      }
  }

  var mostFrequentLabel: String {
    let counts = Dictionary(grouping: store.entries, by: \.topLabel)
      .mapValues(\.count)
    return counts.max(by: { $0.value < $1.value })?.key ?? "-"
  }

  var avgConfidenceText: String {
    guard !store.entries.isEmpty else { return "-" }
    let avg = store.entries.map(\.topConfidence).reduce(0, +) / Float(store.entries.count)
    return "\(Int(avg * 100))%"
  }

  func deleteAll() {
    store.deleteAll()
  }

  func delete(at offsets: IndexSet) {
    store.delete(at: offsets)
  }

  func delete(entry: HistoryEntry) {
    guard let idx = store.entries.firstIndex(where: { $0.id == entry.id }) else { return }
    store.delete(at: IndexSet(integer: idx))
  }
}
