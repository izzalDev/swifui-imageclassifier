import SwiftUI

struct HistoryView: View {
  @ObserveInjection var injection
  @State private var viewModel = HistoryViewModel()

  var body: some View {
    @Bindable var vm = viewModel
    NavigationStack {
      Group {
        if viewModel.entries.isEmpty {
          emptyState
        } else {
          historyList
        }
      }
      .background(Color.page)
      .navigationTitle("History")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if !viewModel.entries.isEmpty {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(role: .destructive) {
              viewModel.showClearConfirm = true
            } label: {
              Image(systemName: "trash")
                .font(.callout)
                .foregroundStyle(Color.danger)
            }
          }
        }
      }
      .confirmationDialog(
        "Clear all history?",
        isPresented: $vm.showClearConfirm,
        titleVisibility: .visible
      ) {
        Button("Clear All", role: .destructive) {
          withAnimation { viewModel.deleteAll() }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("This action cannot be undone.")
      }
      .sheet(item: $vm.selectedEntry) { entry in
        HistoryDetailView(entry: entry)
      }
    }
    .enableInjection()
  }

  // MARK: - Empty State
  private var emptyState: some View {
    VStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(Color.muted)
          .frame(width: 90, height: 90)
        Image(systemName: "clock.badge.xmark")
          .font(.system(size: 36))
          .foregroundStyle(Color.textTertiary)
      }
      VStack(spacing: 6) {
        Text("No History Yet")
          .font(.headline)
          .foregroundStyle(Color.textPrimary)
        Text("Your classification results will\nappear here after you analyze images.")
          .font(.subheadline)
          .foregroundStyle(Color.textSecondary)
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - List
  private var historyList: some View {
    ScrollView {
      VStack(spacing: 14) {
        statsHeader

        ForEach(viewModel.groupedEntries, id: \.label) { group in
          VStack(alignment: .leading, spacing: 6) {
            sectionLabel(group.label)

            VStack(spacing: 0) {
              ForEach(Array(group.entries.enumerated()), id: \.element.id) { index, entry in
                EntryRow(
                  entry: entry,
                  timeString: timeString(for: entry, isToday: group.label == "Today")
                )
                .contentShape(Rectangle())
                .onTapGesture { viewModel.selectedEntry = entry }
                .contextMenu {
                  Button(role: .destructive) {
                    withAnimation { viewModel.delete(entry: entry) }
                  } label: {
                    Label("Delete", systemImage: "trash")
                  }
                }
                if index < group.entries.count - 1 {
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
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.horizontal, 14)
    }
    .background(Color.page)
  }

  private func timeString(for entry: HistoryEntry, isToday: Bool) -> String {
    if isToday {
      return entry.date.formatted(.relative(presentation: .named))
    } else {
      return entry.date.formatted(date: .omitted, time: .shortened)
    }
  }


  // MARK: - Stats Header
  private var statsHeader: some View {
    HStack(spacing: 10) {
      statCard(
        value: "\(viewModel.entries.count)",
        label: "Total",
        icon: "tray.full",
        color: Color.accent
      )
      statCard(
        value: viewModel.mostFrequentLabel,
        label: "Top Class",
        icon: "star",
        color: Color.success
      )
      statCard(
        value: viewModel.avgConfidenceText,
        label: "Avg Score",
        icon: "chart.bar",
        color: Color.warning
      )
    }
  }

  private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
    VStack(spacing: 6) {
      Image(systemName: icon)
        .font(.system(size: 18))
        .foregroundStyle(color)
      Text(value)
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundStyle(Color.textPrimary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      Text(label)
        .font(.caption2)
        .foregroundStyle(Color.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 14)
    .background(Color.surface)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(Color(.separator), lineWidth: 0.5)
    )
  }

  private func sectionLabel(_ text: String) -> some View {
    Text(text.uppercased())
      .font(.caption)
      .fontWeight(.medium)
      .foregroundStyle(.secondary)
      .padding(.horizontal, 4)
  }
}
