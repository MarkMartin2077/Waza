//
//  Color+EXT.swift
//
//
//
//
import SwiftUI
import UIKit

public extension Color {

    // MARK: - Accent

    /// App-wide accent — tatami red. Earned color: only appears on user achievements.
    static let wazaAccent = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.91, green: 0.40, blue: 0.29, alpha: 1) // #E8654A
            : UIColor(red: 0.78, green: 0.25, blue: 0.16, alpha: 1) // #C8412A
    })
    static let wazaAccentHex = "C8412A"

    // MARK: - Paper (backgrounds)

    /// Primary background — warm paper in light, warm near-black in dark
    static let wazaPaper = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.075, green: 0.067, blue: 0.055, alpha: 1) // #13110E
            : UIColor(red: 0.957, green: 0.937, blue: 0.902, alpha: 1) // #F4EFE6
    })

    /// Elevated paper — slightly brighter surface for cards
    static let wazaPaperHi = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.118, green: 0.106, blue: 0.090, alpha: 1) // #1E1B17
            : UIColor(red: 0.980, green: 0.965, blue: 0.929, alpha: 1) // #FAF6ED
    })

    // MARK: - Ink (text & borders)

    /// ink100 — lightest border/divider tone
    static let wazaInk100 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.165, green: 0.149, blue: 0.125, alpha: 1) // #2A2620
            : UIColor(red: 0.925, green: 0.894, blue: 0.831, alpha: 1) // #ECE4D4
    })

    /// ink200 — subtle borders
    static let wazaInk200 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.227, green: 0.208, blue: 0.188, alpha: 1) // #3A3530
            : UIColor(red: 0.878, green: 0.851, blue: 0.796, alpha: 1) // #E0D9CB
    })

    /// ink300 — borders, dividers, inactive elements
    static let wazaInk300 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.353, green: 0.325, blue: 0.282, alpha: 1) // #5A5348
            : UIColor(red: 0.769, green: 0.741, blue: 0.682, alpha: 1) // #C4BDAE
    })

    /// ink400 — placeholder text, muted labels
    static let wazaInk400 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.478, green: 0.447, blue: 0.408, alpha: 1) // #7A7268
            : UIColor(red: 0.604, green: 0.573, blue: 0.522, alpha: 1) // #9A9285
    })

    /// ink500 — secondary text, labels
    static let wazaInk500 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.604, green: 0.573, blue: 0.522, alpha: 1) // #9A9285
            : UIColor(red: 0.447, green: 0.416, blue: 0.373, alpha: 1) // #726A5F
    })

    /// ink600 — body text (secondary emphasis)
    static let wazaInk600 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.769, green: 0.741, blue: 0.682, alpha: 1) // #C4BDAE
            : UIColor(red: 0.271, green: 0.251, blue: 0.227, alpha: 1) // #45403A
    })

    /// ink700 — strong secondary text
    static let wazaInk700 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.878, green: 0.851, blue: 0.796, alpha: 1) // #E0D9CB
            : UIColor(red: 0.165, green: 0.149, blue: 0.125, alpha: 1) // #2A2620
    })

    /// ink900 — primary text (highest contrast)
    static let wazaInk900 = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.957, green: 0.937, blue: 0.902, alpha: 1) // #F4EFE6
            : UIColor(red: 0.075, green: 0.067, blue: 0.055, alpha: 1) // #13110E
    })

    // MARK: - Semantic

    /// Belt blue for progression indicators
    static let wazaBeltBlue = Color(hex: "2B4A7A")

    // MARK: - Hex Init

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: Double(alpha) / 255)
    }

    func asHex(alpha: Bool = false) -> String {
        // Convert Color to UIColor
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alphaValue: CGFloat = 0

        // Use guard to ensure all components can be extracted
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alphaValue) else {
            // Return a default color (black or transparent) if unable to extract components
            return alpha ? "#00000000": "#000000"
        }

        if alpha {
            // Include alpha component in the hex string
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(Float(alphaValue) * 255),
                          lroundf(Float(red) * 255),
                          lroundf(Float(green) * 255),
                          lroundf(Float(blue) * 255))
        } else {
            // Exclude alpha component from the hex string
            return String(format: "#%02lX%02lX%02lX",
                          lroundf(Float(red) * 255),
                          lroundf(Float(green) * 255),
                          lroundf(Float(blue) * 255))
        }
    }
}
