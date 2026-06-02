import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity)
      .padding(.vertical, 15)
      .background(Color.primary)
      .foregroundColor(.page)
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .overlay(
        RoundedRectangle(cornerRadius: 14)
          .stroke(Color.border, lineWidth: 2)
      )
  }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
  static var primaryButton: PrimaryButtonStyle { .init() }
}
