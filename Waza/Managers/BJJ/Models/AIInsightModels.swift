import FoundationModels

// MARK: - Structured Output Types

@Generable
struct AITrainingInsights {
    @Guide(description: "Exactly 3 actionable training insights based on the data provided")
    var insights: [AITrainingInsight]
}

@Generable
struct AITrainingInsight {
    @Guide(description: "Short, specific title — max 8 words")
    var title: String

    @Guide(description: "2-3 sentence explanation of the observed pattern or finding")
    var detail: String

    @Guide(description: "One concrete action to take at the very next training session")
    var actionItem: String

    @Guide(description: "Category — one of: pattern, strength, opportunity, warning")
    var category: String
}
