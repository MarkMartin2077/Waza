import Foundation

enum Mood {
    static let emojis = ["😴", "😐", "🙂", "😊", "🔥"]
    static let labels = ["Tired", "Okay", "Good", "Great", "Fired Up"]

    static func emoji(for rating: Int) -> String {
        guard (1...5).contains(rating) else { return "😐" }
        return emojis[rating - 1]
    }

    static func label(for rating: Int) -> String {
        guard (1...5).contains(rating) else { return "Okay" }
        return labels[rating - 1]
    }
}
