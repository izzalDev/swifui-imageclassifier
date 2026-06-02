import SwiftUI

extension Color {
  static let page = Color(light: "#f5f0eb", dark: "#111008")
  static let surface = Color(light: "#ffffff", dark: "#1c1a14")
  static let muted = Color(light: "#ede8e1", dark: "#2a2620")
  static let textPrimary = Color(light: "#2c1f0e", dark: "#f0e6d0")
  static let textSecondary = Color(light: "#6b5e48", dark: "#d4c4a8")
  static let textTertiary = Color(light: "#9e8b78", dark: "#6b5e48")
  static let primary = Color(light: "#6b3f1a", dark: "#c8a06a")
  static let accent = Color(light: "#8b5e2e", dark: "#a07848")
  static let border = Color(light: "#ddd4c8", dark: "#2e2a22")
  static let success = Color(light: "#4a7c40", dark: "#6aad5a")
  static let warning = Color(light: "#b07020", dark: "#c8942a")
  static let danger = Color(light: "#b03030", dark: "#c85050")
  static let nurlu = Color(hex: "#c8a06a")
  static let ak = Color(hex: "#a07848")
  static let kapadokya = Color(hex: "#4a7a40")
  static let sira = Color(hex: "#7a6848")
}

extension UIColor {
  convenience init(hex: String) {
    let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)

    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: 1.0
    )
  }
}

extension Color {
  init(hex: String) {
    self.init(uiColor: UIColor(hex: hex))
  }

  init(light: String, dark: String) {
    let dynamicColor = UIColor { traitCollection in
      return traitCollection.userInterfaceStyle == .dark
        ? UIColor(hex: dark)
        : UIColor(hex: light)
    }
    self.init(uiColor: dynamicColor)
  }
}
