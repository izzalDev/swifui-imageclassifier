import SwiftUI

struct HomeView: View {
  @ObserveInjection var injection
  @State private var viewModel = HomeViewModel()

  var body: some View {
    @Bindable var vm = viewModel
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
            viewModel.showPicker = true
          } label: {
            Image(systemName: "photo.on.rectangle.angled")
              .font(.callout)
          }
        }
      }
      .cropImagePicker(
        show: $vm.showPicker,
        croppedImage: $vm.croppedImage
      )
      .sheet(item: $vm.selectedEntry) { entry in
        HistoryDetailView(entry: entry)
      }
    }
    .enableInjection()
  }

  private var uploadCard: some View {
    VStack {
      if let croppedImage = viewModel.croppedImage {
        Image(uiImage: croppedImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        Image(systemName: "camera")
          .font(.system(size: 28))
          .foregroundStyle(Color.textSecondary)
          .padding(12)
        Text("No Image is selected")
          .foregroundStyle(Color.textSecondary)
      }
    }
    .frame(maxWidth: .infinity)
    .frame(height: UIScreen.main.bounds.width - 28)
    .background(Color.surface)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .overlay {
      RoundedRectangle(cornerRadius: 14)
        .stroke(Color.border, lineWidth: 2)
    }
  }

  private var analyzeButton: some View {
    Button {
      viewModel.analyze()
    } label: {
      if viewModel.isAnalyzing {
        ProgressView().tint(.textSecondary)
      } else {
        Text("Analyze Image")
      }
    }
    .buttonStyle(.primaryButton)
    .disabled(viewModel.croppedImage == nil || viewModel.isAnalyzing)
  }

  @ViewBuilder
  private var resultSection: some View {
    if !viewModel.results.isEmpty {
      VStack(alignment: .leading, spacing: 6) {
        sectionLabel("Result")

        VStack(spacing: 0) {
          HStack {
            Text("Top prediction")
              .font(.caption)
              .foregroundStyle(Color.textSecondary)
            Spacer()
            if let top = viewModel.topResult {
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

          Divider().padding(.horizontal, 14)

          ForEach(viewModel.results, id: \.label) { item in
            ClassRow(
              label: item.label,
              confidence: item.confidence,
              color: item.color,
              isTop: item.label == viewModel.topResult?.label
            )
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

  @ViewBuilder
  private var recentSection: some View {
    let recent = viewModel.recentEntries
    if !recent.isEmpty {
      VStack(alignment: .leading, spacing: 6) {
        sectionLabel("Recent")

        VStack(spacing: 0) {
          ForEach(Array(recent.enumerated()), id: \.element.id) { index, entry in
            EntryRow(
              entry: entry,
              timeString: entry.date.formatted(.relative(presentation: .named))
            )
            .onTapGesture { viewModel.selectedEntry = entry }
            if index < recent.count - 1 {
              Divider().padding(.leading, 66)
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
}

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
