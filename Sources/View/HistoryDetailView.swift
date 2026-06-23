import SwiftUI

// MARK: - History Detail Sheet
struct HistoryDetailView: View {
  let entry: HistoryEntry
  @Environment(\.dismiss) private var dismiss
  @ObserveInjection var injection

  private var sortedResults: [StoredResult] {
    entry.results.sorted { $0.confidence > $1.confidence }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          // Image
          Group {
            if let img = entry.image {
              Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fit)
            } else {
              ZStack {
                Color.muted
                Image(systemName: "photo")
                  .font(.system(size: 40))
                  .foregroundStyle(Color.textTertiary)
              }
              .frame(height: 240)
            }
          }
          .frame(maxWidth: .infinity)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(Color.border, lineWidth: 1.5)
          )
          .padding(.horizontal, 14)

          // Metadata card
          VStack(spacing: 0) {
            metaRow(
              icon: "calendar",
              label: "Date",
              value: entry.date.formatted(date: .long, time: .shortened)
            )
            Divider().padding(.horizontal, 14)
            metaRow(
              icon: "clock",
              label: "Time",
              value: entry.date.formatted(date: .omitted, time: .complete)
            )
            Divider().padding(.horizontal, 14)
            metaRow(
              icon: "cpu",
              label: "Model",
              value: entry.model.displayName
            )
          }
          .background(Color.surface)
          .clipShape(RoundedRectangle(cornerRadius: 14))
          .overlay(
            RoundedRectangle(cornerRadius: 14)
              .stroke(Color(.separator), lineWidth: 0.5)
          )
          .padding(.horizontal, 14)

          // Results
          VStack(alignment: .leading, spacing: 6) {
            Text("Classification Results".uppercased())
              .font(.caption)
              .fontWeight(.medium)
              .foregroundStyle(.secondary)
              .padding(.horizontal, 4)

            VStack(spacing: 0) {
              let top = sortedResults.first
              ForEach(sortedResults, id: \.label) { result in
                let isTop = result.label == top?.label
                HStack(spacing: 10) {
                  Circle()
                    .fill(Color.labelColor(for: result.label))
                    .frame(width: 8, height: 8)
                  Text(result.label)
                    .font(.subheadline)
                    .fontWeight(isTop ? .semibold : .regular)
                    .foregroundStyle(isTop ? Color.textPrimary : Color.textSecondary)
                    .frame(minWidth: 80, alignment: .leading)
                  ProgressView(value: result.confidence, total: 1)
                    .tint(Color.labelColor(for: result.label))
                  Text("\(Int(result.confidence * 100))%")
                    .font(.caption)
                    .fontWeight(isTop ? .semibold : .regular)
                    .foregroundStyle(isTop ? Color.textPrimary : Color.textSecondary)
                    .frame(width: 32, alignment: .trailing)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)

                if result.label != sortedResults.last?.label {
                  Divider().padding(.horizontal, 14)
                }
              }
            }
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 0.5)
            )
          }
          .padding(.horizontal, 14)
        }
        .padding(.bottom, 24)
      }
      .background(Color.page)
      .navigationTitle(entry.topLabel)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") { dismiss() }
            .fontWeight(.semibold)
        }
      }
    }
    .enableInjection()
  }

  private func metaRow(icon: String, label: String, value: String) -> some View {
    HStack {
      Image(systemName: icon)
        .font(.subheadline)
        .foregroundStyle(Color.accent)
        .frame(width: 24)
      Text(label)
        .font(.subheadline)
        .foregroundStyle(Color.textSecondary)
      Spacer()
      Text(value)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(Color.textPrimary)
        .multilineTextAlignment(.trailing)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 12)
  }
}
