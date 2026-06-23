import SwiftUI

/// Shared row component used by both HomeView (recent) and HistoryView (grouped list).
/// Pass a pre-formatted `timeString` so each context can control the display format.
struct EntryRow: View {
  let entry: HistoryEntry
  let timeString: String

  @ObserveInjection var injection

  var body: some View {
    HStack(spacing: 12) {
      // Thumbnail
      Group {
        if let img = entry.image {
          Image(uiImage: img)
            .resizable()
            .scaledToFill()
        } else {
          ZStack {
            Color.muted
            Image(systemName: "photo")
              .font(.system(size: 14))
              .foregroundStyle(Color.textTertiary)
          }
        }
      }
      .frame(width: 40, height: 40)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.border, lineWidth: 1)
      )

      // Label + time
      VStack(alignment: .leading, spacing: 2) {
        HStack(spacing: 5) {
          Circle()
            .fill(Color.labelColor(for: entry.topLabel))
            .frame(width: 6, height: 6)
          Text(entry.topLabel)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(Color.textPrimary)
        }
        Text(timeString)
          .font(.caption)
          .foregroundStyle(Color.textSecondary)
      }

      Spacer()

      // Confidence + chevron
      VStack(alignment: .trailing, spacing: 3) {
        Text("\(Int(entry.topConfidence * 100))%")
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundStyle(confidenceColor)
        Image(systemName: "chevron.right")
          .font(.caption2)
          .fontWeight(.semibold)
          .foregroundStyle(Color.textTertiary)
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 12)
    .enableInjection()
  }

  private var confidenceColor: Color {
    let c = entry.topConfidence
    if c >= 0.75 { return Color.success }
    if c >= 0.5  { return Color.warning }
    return Color.danger
  }
}
