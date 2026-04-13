import SwiftUI

// MARK: - Technique Category

enum TechniqueCategory: String, Codable, CaseIterable, Sendable {
    case guardPlay = "guard"
    case passing
    case takedowns
    case submissions
    case escapes
    case sweeps
    case uncategorized

    var displayName: String {
        switch self {
        case .guardPlay:     return "Guard"
        case .passing:       return "Passing"
        case .takedowns:     return "Takedowns"
        case .submissions:   return "Submissions"
        case .escapes:       return "Escapes"
        case .sweeps:        return "Sweeps"
        case .uncategorized: return "Uncategorized"
        }
    }

    var iconName: String {
        switch self {
        case .guardPlay:     return "shield.fill"
        case .passing:       return "arrow.right.circle.fill"
        case .takedowns:     return "arrow.down.circle.fill"
        case .submissions:   return "hand.raised.fill"
        case .escapes:       return "figure.run"
        case .sweeps:        return "arrow.left.arrow.right.circle.fill"
        case .uncategorized: return "questionmark.circle.fill"
        }
    }

    /// Maps preset focus area names to categories.
    static func infer(from focusAreaName: String) -> TechniqueCategory {
        let lower = focusAreaName.lowercased()
        if lower.contains("guard") && !lower.contains("pass") { return .guardPlay }
        if lower.contains("pass") { return .passing }
        if lower.contains("takedown") || lower.contains("wrestling") { return .takedowns }
        if lower.contains("sweep") { return .sweeps }
        if lower.contains("submission") || lower.contains("triangle") || lower.contains("armbar")
            || lower.contains("choke") || lower.contains("leg lock") || lower.contains("heel hook") { return .submissions }
        if lower.contains("escape") { return .escapes }
        return .uncategorized
    }
}

// MARK: - ProgressionStage Visual Properties

extension ProgressionStage {
    var color: Color {
        switch self {
        case .learning:  return .gray
        case .drilling:  return .blue
        case .applying:  return .purple
        case .polishing: return .green
        }
    }

    var opacity: Double {
        switch self {
        case .learning:  return 0.4
        case .drilling:  return 0.6
        case .applying:  return 0.8
        case .polishing: return 1.0
        }
    }

    var iconName: String {
        switch self {
        case .learning:  return "book.fill"
        case .drilling:  return "repeat.circle.fill"
        case .applying:  return "bolt.fill"
        case .polishing: return "star.fill"
        }
    }

    /// Minimum practice count to suggest promotion TO this stage.
    var promotionThreshold: Int? {
        switch self {
        case .learning:  return nil
        case .drilling:  return 3
        case .applying:  return 8
        case .polishing: return 15
        }
    }

    /// The suggested next stage given a practice count, or nil if already at or above.
    static func suggestedPromotion(currentStage: ProgressionStage, practiceCount: Int) -> ProgressionStage? {
        let candidates: [ProgressionStage] = [.drilling, .applying, .polishing]
        for candidate in candidates {
            guard let threshold = candidate.promotionThreshold else { continue }
            if currentStage.order < candidate.order && practiceCount >= threshold {
                return candidate
            }
        }
        return nil
    }
}
