import SwiftUI

struct SettingsView: View {
  @ObserveInjection var injection
  @State private var viewModel = SettingsViewModel()

  var body: some View {
    @Bindable var vm = viewModel
    NavigationStack {
      List {
        classificationSection
        modelSection  // Pindah ke atas agar lebih terlihat
        historySection
        feedbackSection
        aboutSection
      }
      .listStyle(.insetGrouped)
      .scrollContentBackground(.hidden)
      .background(Color.page)
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $vm.showAbout) {
        AboutView()
      }
      .confirmationDialog(
        "Clear History?",
        isPresented: $vm.showClearHistoryConfirm,
        titleVisibility: .visible
      ) {
        Button("Clear All History", role: .destructive) {
          withAnimation { viewModel.clearHistory() }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("All saved classification records will be permanently deleted.")
      }
    }
    .enableInjection()
  }

  // MARK: - Classification Settings

  private var classificationSection: some View {
    @Bindable var vm = viewModel
    return Section {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Label("Confidence Threshold", systemImage: "slider.horizontal.3")
            .font(.subheadline)
            .foregroundStyle(Color.textPrimary)
          Spacer()
          Text("\(Int(viewModel.settings.confidenceThreshold * 100))%")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.accent)
            .monospacedDigit()
        }
        Slider(value: $vm.settings.confidenceThreshold, in: 0.1...0.95, step: 0.05)
          .tint(Color.accent)
        Text("Results below this threshold are dimmed in the output.")
          .font(.caption)
          .foregroundStyle(Color.textSecondary)
      }
      .padding(.vertical, 4)

      settingsToggle(
        title: "Show All Results",
        subtitle: "Display all classes even with low confidence",
        icon: "list.bullet.indent",
        iconColor: Color.accent,
        binding: $vm.settings.showAllResults
      )
    } header: {
      sectionHeader("Classification")
    }
    .listRowBackground(Color.surface)
  }

  // MARK: - Model Section

  private var modelSection: some View {
    @Bindable var vm = viewModel
    return Section {
      Picker(selection: $vm.settings.selectedModel) {
        ForEach(ModelType.allCases, id: \.self) { model in
          Text(model.displayName)
            .tag(model)
        }
      } label: {
        Label {
          Text("Model")
            .font(.subheadline)
            .foregroundStyle(Color.textPrimary)
        } icon: {
          settingsIcon("cpu.fill", color: Color(hex: "#7a48b0"))
        }
      }
      .tint(Color.accent)
      .onChange(of: vm.settings.selectedModel) { _, _ in
        // Model akan otomatis reload via NotificationCenter
      }

      infoRow(
        icon: "scale.3d",
        iconColor: Color(hex: "#3070b0"),
        title: "Format",
        value: "ONNX"
      )
      infoRow(
        icon: "photo.artframe",
        iconColor: Color(hex: "#30908a"),
        title: "Input Size",
        value: "128 × 128 px"
      )
      infoRow(
        icon: "tag.fill",
        iconColor: Color(hex: "#b07830"),
        title: "Classes",
        value: "Ak · Kapadokya · Nurlu · Sira"
      )
    } header: {
      sectionHeader("Model")
    }
    .listRowBackground(Color.surface)
  }

  // MARK: - History Settings

  private var historySection: some View {
    @Bindable var vm = viewModel
    return Section {
      settingsToggle(
        title: "Save Images",
        subtitle: "Store thumbnails alongside classification history",
        icon: "photo.on.rectangle",
        iconColor: Color.primary,
        binding: $vm.settings.saveHistoryImages
      )

      HStack {
        Label {
          VStack(alignment: .leading, spacing: 2) {
            Text("Saved Records")
              .font(.subheadline)
              .foregroundStyle(Color.textPrimary)
            Text(
              "\(viewModel.historyCount) classification\(viewModel.historyCount == 1 ? "" : "s")"
            )
            .font(.caption)
            .foregroundStyle(Color.textSecondary)
          }
        } icon: {
          settingsIcon("clock.fill", color: Color.warning)
        }
        Spacer()
      }

      Button(role: .destructive) {
        viewModel.showClearHistoryConfirm = true
      } label: {
        Label {
          Text("Clear All History")
            .font(.subheadline)
        } icon: {
          settingsIcon("trash.fill", color: Color.danger)
        }
      }
      .disabled(viewModel.isHistoryEmpty)
    } header: {
      sectionHeader("History")
    }
    .listRowBackground(Color.surface)
  }

  // MARK: - Feedback Section

  private var feedbackSection: some View {
    @Bindable var vm = viewModel
    return Section {
      settingsToggle(
        title: "Haptic Feedback",
        subtitle: "Vibrate on classification complete",
        icon: "iphone.radiowaves.left.and.right",
        iconColor: Color.success,
        binding: $vm.settings.hapticFeedback
      )
    } header: {
      sectionHeader("Feedback")
    }
    .listRowBackground(Color.surface)
  }

  // MARK: - About Section

  private var aboutSection: some View {
    Section {
      Button {
        viewModel.showAbout = true
      } label: {
        HStack {
          Label {
            Text("About Almont Classifier")
              .font(.subheadline)
              .foregroundStyle(Color.textPrimary)
          } icon: {
            settingsIcon("info.circle.fill", color: Color.accent)
          }
          Spacer()
          Image(systemName: "chevron.right")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.textTertiary)
        }
      }

      infoRow(
        icon: "number",
        iconColor: Color.textTertiary,
        title: "Version",
        value: viewModel.appVersion
      )
    } header: {
      sectionHeader("About")
    }
    .listRowBackground(Color.surface)
  }

  // MARK: - Helpers

  private func sectionHeader(_ text: String) -> some View {
    Text(text.uppercased())
      .font(.caption)
      .fontWeight(.medium)
      .foregroundStyle(.secondary)
      .padding(.horizontal, 4)
  }

  private func settingsIcon(_ name: String, color: Color) -> some View {
    Image(systemName: name)
      .font(.system(size: 13, weight: .semibold))
      .foregroundStyle(.white)
      .frame(width: 28, height: 28)
      .background(color)
      .clipShape(RoundedRectangle(cornerRadius: 7))
  }

  private func settingsToggle(
    title: String,
    subtitle: String,
    icon: String,
    iconColor: Color,
    binding: Binding<Bool>
  ) -> some View {
    HStack(spacing: 12) {
      settingsIcon(icon, color: iconColor)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.subheadline)
          .foregroundStyle(Color.textPrimary)
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(Color.textSecondary)
      }
      Spacer()
      Toggle("", isOn: binding)
        .tint(Color.accent)
        .labelsHidden()
    }
    .padding(.vertical, 2)
  }

  private func infoRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
    HStack(spacing: 12) {
      settingsIcon(icon, color: iconColor)
      Text(title)
        .font(.subheadline)
        .foregroundStyle(Color.textSecondary)
      Spacer()
      Text(value)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(Color.textPrimary)
        .multilineTextAlignment(.trailing)
    }
    .padding(.vertical, 2)
  }
}

// MARK: - About Sheet

private struct AboutView: View {
  @Environment(\.dismiss) private var dismiss
  @ObserveInjection var injection

  private let classes: [(name: String, color: Color, desc: String)] = [
    ("Ak", .ak, "Light-colored premium variety"),
    ("Kapadokya", .kapadokya, "Green-hued regional variety"),
    ("Nurlu", .nurlu, "Golden mid-size variety"),
    ("Sira", .sira, "Brown robust variety"),
  ]

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // Hero
          VStack(spacing: 12) {
            ZStack {
              Circle()
                .fill(
                  LinearGradient(
                    colors: [Color.accent.opacity(0.3), Color.primary.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                )
                .frame(width: 90, height: 90)
              Image(systemName: "leaf.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.accent)
            }

            Text("Almont Classifier")
              .font(.title2)
              .fontWeight(.bold)
              .foregroundStyle(Color.textPrimary)

            Text(
              "An AI-powered almond variety classifier using a Convolutional Autoencoder + SVM model to identify four distinct almond types from photographs."
            )
            .font(.subheadline)
            .foregroundStyle(Color.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
          }
          .padding(.horizontal, 24)
          .padding(.top, 8)

          // Classes
          VStack(alignment: .leading, spacing: 8) {
            Text("Supported Varieties".uppercased())
              .font(.caption)
              .fontWeight(.medium)
              .foregroundStyle(.secondary)
              .padding(.horizontal, 4)

            VStack(spacing: 0) {
              ForEach(classes, id: \.name) { cls in
                HStack(spacing: 12) {
                  Circle()
                    .fill(cls.color)
                    .frame(width: 10, height: 10)
                  Text(cls.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                  Spacer()
                  Text(cls.desc)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                if cls.name != classes.last?.name {
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
            .padding(.horizontal, 14)
          }

          // Tech stack
          VStack(alignment: .leading, spacing: 8) {
            Text("Technology".uppercased())
              .font(.caption)
              .fontWeight(.medium)
              .foregroundStyle(.secondary)
              .padding(.horizontal, 4)

            VStack(spacing: 10) {
              techBadge("Core ML Runtime", icon: "cpu.fill", subtitle: "ONNX Runtime for iOS")
              techBadge("SwiftUI", icon: "swift", subtitle: "Native iOS UI framework")
              techBadge("CAE + SVM", icon: "waveform", subtitle: "Feature extraction + classification")
            }
            .padding(.horizontal, 14)
          }
        }
        .padding(.bottom, 32)
      }
      .background(Color.page)
      .navigationTitle("About")
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

  private func techBadge(_ title: String, icon: String, subtitle: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 16))
        .foregroundStyle(Color.accent)
        .frame(width: 32)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(Color.textPrimary)
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(Color.textSecondary)
      }
      Spacer()
    }
    .padding(12)
    .background(Color.surface)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.border, lineWidth: 1)
    )
  }
}
