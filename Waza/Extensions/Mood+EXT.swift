import Foundation

enum Mood {
    static let emojis = ["😴", "😐", "🙂", "😊", "🔥"]
    static let labels = ["Tired", "Okay", "Good", "Great", "Fired Up"]
    /// Muted SF Symbol alternatives — aligned to the editorial ink-and-paper palette.
    /// Intensity ramps from low (moon) through neutral (minus) to high (flame).
    static let symbols = ["moon.zzz.fill", "minus.circle.fill", "plus.circle.fill", "star.fill", "flame.fill"]

    static func emoji(for rating: Int) -> String {
        guard (1...5).contains(rating) else { return "😐" }
        return emojis[rating - 1]
    }

    static func label(for rating: Int) -> String {
        guard (1...5).contains(rating) else { return "Okay" }
        return labels[rating - 1]
    }

    static func symbol(for rating: Int) -> String {
        guard (1...5).contains(rating) else { return "minus.circle.fill" }
        return symbols[rating - 1]
    }
}
