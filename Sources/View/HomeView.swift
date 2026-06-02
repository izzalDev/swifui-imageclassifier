import SwiftUI

struct HomeView: View {
  @ObserveInjection var injection
  @State private var croppedImage: UIImage?
  @State private var show: Bool = false
  @State private var results: [(label: String, confidence: Float, color: Color)] = [
    ("Ak", 0.92, .blue),
    ("Kapadokya", 0.05, .green),
    ("Nurlu", 0.02, .orange),
    ("Sira", 0.01, .red),
  ]

  var topResult: (label: String, confidence: Float, color: Color)? {
    results.max(by: { $0.confidence < $1.confidence })
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 14) {
          uploadCard
          analyzeButton
          resultSection
          recentSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 14)
      }
      .background(Color.page)
      .navigationTitle("Almont Classifier")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            show = true
          } label: {
            Image(systemName: "photo.on.rectangle.angled")
              .font(.callout)
          }
        }
      }
      .cropImagePicker(
        options: [.circle, .square, .rectangle],
        show: $show,
        croppedImage: $croppedImage
      )
    }
    .enableInjection()
  }

  private var uploadCard: some View {
    VStack {
      Image(systemName: "camera")
        .font(.system(size: 28))
        .foregroundStyle(Color.textSecondary)
        .padding(12)
      Text("No Image is selected")
        .foregroundStyle(Color.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .frame(height: UIScreen.main.bounds.width - 28)  // kotak sempurna
    .background(Color.surface)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .overlay {
      RoundedRectangle(cornerRadius: 14)
        .stroke(Color.border, lineWidth: 2)
    }
  }

  private var analyzeButton: some View {
    Button {
    } label: {
      Text("Analyze Image")
    }
    .buttonStyle(.primaryButton)

  }

  @ViewBuilder
  private var resultSection: some View {
    if !results.isEmpty {
      VStack(alignment: .leading, spacing: 6) {
        sectionLabel("Result")

        VStack(spacing: 0) {
          // Header
          HStack {
            Text("Top prediction")
              .font(.caption)
              .foregroundStyle(Color.textSecondary)
            Spacer()
            if let top = topResult {
              Text("\(Int(top.confidence * 100))% confidence")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.green)
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.12))
                .clipShape(Capsule())
            }
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 10)

          ForEach(results, id: \.label) { item in
            ClassRow(
              label: item.label,
              confidence: item.confidence,
              color: item.color,
              isTop: item.label == topResult?.label
            )
            if item.label != results.last?.label {
              Divider().padding(.leading, 14)
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
    }
  }

  private func sectionLabel(_ text: String) -> some View {
    Text(text.uppercased())
      .font(.caption)
      .fontWeight(.medium)
      .foregroundStyle(.secondary)
      .padding(.horizontal, 4)
  }

  private var recentSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      sectionLabel("Recent")

      VStack(spacing: 0) {
        RecentRow(label: "Ak", time: "2 min ago", confidence: 0.88)
        Divider().padding(.leading, 56)
        RecentRow(label: "Kapadokya", time: "15 min ago", confidence: 0.76)
      }
      .background(Color.surface)
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .overlay(
        RoundedRectangle(cornerRadius: 14)
          .stroke(Color(.separator), lineWidth: 0.5)
      )
    }
  }
}
// MARK: - ClassRow

private struct ClassRow: View {
  let label: String
  let confidence: Float
  let color: Color
  let isTop: Bool

  @ObserveInjection var injection
  var body: some View {
    HStack(spacing: 10) {
      Circle()
        .fill(color)
        .frame(width: 8, height: 8)

      Text(label)
        .font(.subheadline)
        .fontWeight(isTop ? .semibold : .regular)
        .foregroundStyle(isTop ? Color.textPrimary : Color.textSecondary)
        .frame(minWidth: 80, alignment: .leading)

      ProgressView(value: confidence, total: 1)
        .tint(.green)
      Text("\(Int(confidence * 100))%")
        .font(.caption)
        .fontWeight(isTop ? .semibold : .regular)
        .foregroundStyle(isTop ? Color.textPrimary : Color.textSecondary)
        .frame(width: 32, alignment: .trailing)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 14)
    .enableInjection()
  }
}

// MARK: - RecentRow

private struct RecentRow: View {
  let label: String
  let time: String
  let confidence: Float
  @ObserveInjection var injection

  var body: some View {
    HStack(spacing: 10) {
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(.systemGray5))
        .frame(width: 36, height: 36)
        .overlay(
          Image(systemName: "photo")
            .font(.system(size: 14))
            .foregroundStyle(Color.textSecondary)
        )

      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(Color.textPrimary)
        Text(time)
          .font(.caption).foregroundStyle(Color.textSecondary)
      }

      Spacer()

      Text("\(Int(confidence * 100))%")
        .font(.subheadline)
        .foregroundStyle(Color.textSecondary)

      Image(systemName: "chevron.right")
        .font(.caption).fontWeight(.semibold)
        .foregroundStyle(Color.textTertiary)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 14)
    .enableInjection()
  }
}
