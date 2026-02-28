import Foundation

extension CLAGameLibrary {

    // MARK: - Takedowns

    static let takedownGames: [CLAGameModel] = [
        CLAGameModel(
            gameId: "builtin-td-01",
            name: "Grip Battle",
            objective: "Win the grip-fighting game. Score 1 point for achieving a dominant grip (collar-sleeve or double-sleeve), 3 points for a completed takedown from your grip.",
            skillLevel: .beginner,
            position: "Takedowns",
            focusArea: "Grip Fighting",
            taskConstraints: [
                "You cannot touch the legs — upper-body grips only",
                "You must break any grip your partner achieves within 3 seconds or they score",
                "A completed trip from a dominant grip scores 3 points"
            ],
            environmentConstraints: [
                "Round duration: 3 minutes",
                "Both players start standing"
            ],
            individualConstraints: [
                "Get your grip before you try to break theirs"
            ],
            expectedDiscoveries: [
                "Inside position beats outside position for grip control",
                "Breaking grips with hip rotation is more efficient than arm pulling",
                "Establishing grip first changes the entire dynamic of the exchange"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-td-02",
            name: "Double Leg Defense",
            objective: "Successfully defend double-leg takedown attempts. Score 1 point per defense, 2 bonus points for a counter-takedown.",
            skillLevel: .beginner,
            position: "Takedowns",
            focusArea: "Takedown Defense",
            taskConstraints: [
                "Attacker must commit to a real attempt — feints don't count as reps",
                "You cannot step back to defend — must defend from your base",
                "Score 2 bonus points for spinning behind your partner during defense"
            ],
            environmentConstraints: [
                "Round duration: 3 minutes",
                "Both players start standing"
            ],
            individualConstraints: [
                "Sprawl with your hips — not your weight — first"
            ],
            expectedDiscoveries: [
                "The sprawl timing window is earlier than it feels",
                "Crossface direction after the sprawl determines your counter options",
                "Hip connection level during the shot tells you whether to sprawl or redirect"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-td-03",
            name: "Pull or Shoot Decision",
            objective: "Make the correct decision: shoot for a takedown or pull guard. Score 1 point for each correct decision executed cleanly.",
            skillLevel: .intermediate,
            position: "Takedowns",
            focusArea: "Takedown vs. Guard Pull",
            taskConstraints: [
                "You must verbally declare 'shoot' or 'pull' before committing",
                "A wrong decision (attempted but failed in the declared direction) costs 1 point",
                "Score 2 bonus points for a takedown when partner expected a guard pull"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Both players start standing in sport BJJ distance"
            ],
            individualConstraints: [
                "Read the pressure — if they're reaching for collars, shoot; if they're backing up, pull"
            ],
            expectedDiscoveries: [
                "Grip fighting reveals opponent's takedown vs. guard pull preference",
                "The transition between pulling and shooting is a vulnerability moment for both players",
                "Faking a guard pull and shooting is a high-percentage counter-strategy"
            ]
        )
    ]

    // MARK: - Positional Control

    static let positionalGames: [CLAGameModel] = [
        CLAGameModel(
            gameId: "builtin-pc-01",
            name: "Domination Station",
            objective: "Maintain side control or mount for the full round. Score 1 point per 10 continuous seconds of control, penalty for losing position.",
            skillLevel: .beginner,
            position: "Positional",
            focusArea: "Top Control",
            taskConstraints: [
                "No submissions — positional control only",
                "If you lose position you must restart from side control — no chasing",
                "Bonus point for successfully transitioning between side control and mount"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Bottom player actively escapes — no cooperation"
            ],
            individualConstraints: [
                "Weight distribution beats squeezing every time"
            ],
            expectedDiscoveries: [
                "Where you put your head in side control determines which escape is available",
                "Anticipating the escape is more effective than reacting to it",
                "Transition timing between positions is its own skill"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-pc-02",
            name: "The Gauntlet",
            objective: "Survive consecutive positional disadvantages (side control → mount → back). Score 1 point per position survived. Top player applies genuine pressure.",
            skillLevel: .advanced,
            position: "Positional",
            focusArea: "Positional Survival",
            taskConstraints: [
                "Positions advance on a 90-second timer",
                "Bottom player must escape to neutral to stop the sequence",
                "Top player applies controlled but genuine pressure"
            ],
            environmentConstraints: [
                "Round duration: Until escape or sequence complete",
                "Structured escalation: side control → mount → back"
            ],
            individualConstraints: [
                "Mental toughness — the goal is survival, not reversal"
            ],
            expectedDiscoveries: [
                "Managing energy across three positions requires strategic effort allocation",
                "Transitions between positions are often the escape opportunity",
                "Defenses that work from side control fail from mount — position-specific knowledge matters"
            ]
        )
    ]
}
