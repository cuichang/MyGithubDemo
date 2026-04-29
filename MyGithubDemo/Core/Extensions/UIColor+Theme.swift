//
//  UIColor+Theme.swift
//  MyGithubDemo
//

import UIKit

extension UIColor {

    // MARK: - Theme Colors

    static var themePrimary: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "58A6FF")
                : UIColor(hex: "0366D6")
        }
    }

    static var themeBackground: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "0D1117")
                : UIColor(hex: "FFFFFF")
        }
    }

    static var themeSecondaryBackground: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "161B22")
                : UIColor(hex: "F6F8FA")
        }
    }

    static var themeText: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "C9D1D9")
                : UIColor(hex: "24292F")
        }
    }

    static var themeSecondaryText: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "8B949E")
                : UIColor(hex: "57606A")
        }
    }

    static var themeSeparator: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "21262D")
                : UIColor(hex: "D0D7DE")
        }
    }

    static var themeCard: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "161B22")
                : UIColor(hex: "F6F8FA")
        }
    }

    static var themeSuccess: UIColor {
        UIColor(hex: "238636")
    }

    static var themeWarning: UIColor {
        UIColor(hex: "D29922")
    }

    static var themeError: UIColor {
        UIColor(hex: "CF222E")
    }

    // MARK: - Initializer

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
