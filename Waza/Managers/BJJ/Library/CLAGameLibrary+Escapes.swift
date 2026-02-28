import Foundation

extension CLAGameLibrary {

    // MARK: - Escapes

    static let escapeGames: [CLAGameModel] = [
        CLAGameModel(
            gameId: "builtin-es-01",
            name: "Mount Escape Mission",
            objective: "Escape from mount to half guard or better before a submission is finished. Score 1 point per escape; 3 penalty points per submission received.",
            skillLevel: .beginner,
            position: "Escapes",
            focusArea: "Mount Escape",
            taskConstraints: [
                "You must work continuously — no stalling",
                "You cannot bridge as your first move — elbow-knee escape first",
                "Score a bonus point for reversing to top position"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Top player starts high mount with active submission attempts"
            ],
            individualConstraints: [
                "Get to your side before you bridge — side escaping is always safer"
            ],
            expectedDiscoveries: [
                "Elbow position relative to the knee determines which escape is available",
                "A bump-and-roll requires timing more than strength",
                "Creating space with a frame is the gateway to any escape"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-es-02",
            name: "Side Control Jailbreak",
            objective: "Escape side control and return to guard or achieve a reversal. Score 1 for full guard recovery, 0.5 for half guard, 3 for reversal.",
            skillLevel: .beginner,
            position: "Escapes",
            focusArea: "Side Control Escape",
            taskConstraints: [
                "You cannot turn away from your partner (giving your back)",
                "Attempt guard recovery within 10 seconds of creating a frame",
                "Top player can transition between side control, north-south, and knee-on-belly"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Reset from side control after each escape or submission"
            ],
            individualConstraints: [
                "Frame first, move second — never push without a frame"
            ],
            expectedDiscoveries: [
                "Hip direction and guard recovery direction should match",
                "The underhook on the far arm changes everything from side control",
                "Connecting your elbow to your knee blocks knee-on-belly transitions"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-es-03",
            name: "Back Escape Puzzle",
            objective: "Escape from back mount (partner has both hooks) before being choked. Score 1 point per escape by achieving side-by-side hip position.",
            skillLevel: .intermediate,
            position: "Escapes",
            focusArea: "Back Escape",
            taskConstraints: [
                "You cannot turn into your partner — only escape to the mat-side",
                "You must protect the neck before any other movement",
                "Score a bonus point for trapping an arm during the escape"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Top player must maintain active choking attempts"
            ],
            individualConstraints: [
                "Chin to chest, then slide — protect before you move"
            ],
            expectedDiscoveries: [
                "Shoulder direction determines which hook you strip first",
                "Bringing hips down removes a hook more effectively than standing",
                "The seat-belt grip breaks differently from each side"
            ],
            safetyNotes: "Tap immediately when any choke is locked in — do not wait to feel pressure."
        ),
        CLAGameModel(
            gameId: "builtin-es-04",
            name: "Knee-on-Belly Bounce",
            objective: "Escape from knee-on-belly to a defensive guard position or reverse to top. Score 1 point per escape within 5 seconds of its establishment.",
            skillLevel: .beginner,
            position: "Escapes",
            focusArea: "Knee-on-Belly Escape",
            taskConstraints: [
                "Escape proactively — no stalling under the weight",
                "You cannot grab the KOB leg with both hands — one hand only",
                "Bonus point for capturing the leg and sweeping to top"
            ],
            environmentConstraints: [
                "Round duration: 3 minutes",
                "Top player re-establishes KOB after every escape"
            ],
            individualConstraints: [
                "Move your hips before your hands — hip movement creates the space"
            ],
            expectedDiscoveries: [
                "Shrimping away and shrimping into are two different escapes",
                "Framing on the hip vs. the knee changes the direction of escape",
                "KOB transitions to mount or across — predict which before moving"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-es-05",
            name: "North-South Navigation",
            objective: "Escape from north-south control. Score by returning to side-by-side position or achieving a submission grip on the top player.",
            skillLevel: .intermediate,
            position: "Escapes",
            focusArea: "North-South Escape",
            taskConstraints: [
                "You cannot bridge into your partner — work laterally",
                "Keep your elbows inside at all times",
                "Score 2 bonus points for achieving a kimura grip from north-south"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Top player maintains north-south with hip-to-hip pressure"
            ],
            individualConstraints: [
                "North-south is your opportunity — the kimura is always there"
            ],
            expectedDiscoveries: [
                "Hip direction from north-south mirrors the escape direction",
                "The kimura setup turns a defensive position into an offensive one",
                "Connecting your arms as a frame prevents the top player from floating"
            ]
        )
    ]
}
