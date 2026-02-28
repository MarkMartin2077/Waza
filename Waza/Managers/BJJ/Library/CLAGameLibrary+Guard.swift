import Foundation

extension CLAGameLibrary {

    // MARK: - Guard Retention

    static let guardRetentionGames: [CLAGameModel] = [
        CLAGameModel(
            gameId: "builtin-gr-01",
            name: "Butterfly Shield",
            objective: "Maintain butterfly guard for the full round. Earn 1 point each time you successfully re-establish hooks after they are stripped.",
            skillLevel: .beginner,
            position: "Guard",
            focusArea: "Guard Retention",
            taskConstraints: [
                "You cannot use your hands to grip the mat",
                "You must attempt a sweep if you re-establish hooks twice in a row",
                "Score 3 bonus points for any sweep completed"
            ],
            environmentConstraints: [
                "Round duration: 3 minutes",
                "Start from butterfly guard every reset"
            ],
            individualConstraints: [
                "Stay calm — panic is your opponent's greatest weapon"
            ],
            expectedDiscoveries: [
                "Hip escapes become more instinctive under pressure",
                "Torso angle changes which hooks are vulnerable",
                "Framing creates space more effectively than brute strength"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-gr-02",
            name: "Half Guard Survival",
            objective: "Survive in half guard and work to recover full guard or achieve under-hook dominance. Score 1 point for recovering full guard, 2 for getting the under-hook.",
            skillLevel: .beginner,
            position: "Guard",
            focusArea: "Guard Retention",
            taskConstraints: [
                "You must attempt a sweep within 30 seconds of getting the under-hook",
                "No grabbing your own collar or belt",
                "2 penalty points if you end up flat on your back"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Top player starts with north-south underhook pressure"
            ],
            individualConstraints: [
                "Focus on hip positioning rather than hand fighting"
            ],
            expectedDiscoveries: [
                "The knee shield changes the dynamic of the pressure game",
                "Connection to the hip is more important than arm position",
                "Coming to your side prevents flattening"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-gr-03",
            name: "De La Riva Off-Balance",
            objective: "Maintain De La Riva guard and score by off-balancing your partner. 1 point per off-balance, 3 points for a completed sweep.",
            skillLevel: .intermediate,
            position: "Guard",
            focusArea: "Guard Retention",
            taskConstraints: [
                "You must maintain the DLR hook at all times or the point goes to the top player",
                "You may not grip the sleeve — collar and ankle grips only",
                "You must attempt a sweep within 10 seconds of getting a collar grip"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Top player actively tries to pass on every rep"
            ],
            individualConstraints: [
                "Think of your hook as the steering wheel — your whole game flows from it"
            ],
            expectedDiscoveries: [
                "Grip sequencing matters more than grip strength",
                "Off-balancing forward opens berimbolo entries",
                "The lasso hand threatens equally from the same position"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-gr-04",
            name: "Spider Web Maintenance",
            objective: "Hold spider guard (lasso or sleeve + foot-on-hip) for the duration. Points for sweeps, penalties for losing both connections simultaneously.",
            skillLevel: .intermediate,
            position: "Guard",
            focusArea: "Guard Retention",
            taskConstraints: [
                "If both connections break simultaneously you must reset",
                "You must threaten a triangle within 30 seconds of establishing both hooks",
                "Top player can stand and back away"
            ],
            environmentConstraints: [
                "Round duration: 3 minutes",
                "Start fresh from spider guard each round"
            ],
            individualConstraints: [
                "Use leg push and pull like puppet strings"
            ],
            expectedDiscoveries: [
                "Hip angle determines which sweep is available",
                "Keeping one hook active is enough to prevent passing",
                "Triangles open naturally when the elbow clears the knee"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-gr-05",
            name: "Closed Guard Posture War",
            objective: "Maintain closed guard while consistently breaking your partner's posture. Score for each successful posture break held for 3+ seconds.",
            skillLevel: .beginner,
            position: "Guard",
            focusArea: "Guard Retention",
            taskConstraints: [
                "No submission attempts — posture breaking only",
                "Top player must actively posture up after every break",
                "You must use a different breaking technique each attempt"
            ],
            environmentConstraints: [
                "Round duration: 3 minutes",
                "Both players start fresh each rep"
            ],
            individualConstraints: [
                "Break when they're unbalanced, not when they're set"
            ],
            expectedDiscoveries: [
                "Angle change happens before the posture break, not after",
                "Hip connection is more powerful than arm pulling",
                "The break creates the attack, not the other way around"
            ]
        )
    ]

    // MARK: - Guard Passing

    static let guardPassingGames: [CLAGameModel] = [
        CLAGameModel(
            gameId: "builtin-gp-01",
            name: "The Plow",
            objective: "Pass using pressure-based techniques only. Score 1 point per pass to a dominant position (side control, knee-on-belly, or mount).",
            skillLevel: .beginner,
            position: "Passing",
            focusArea: "Guard Passing",
            taskConstraints: [
                "No speed passing — every pass must use controlled pressure",
                "You must achieve shoulder connection before initiating the pass",
                "Bonus point for establishing knee-on-belly before side control"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Guard player starts in closed guard"
            ],
            individualConstraints: [
                "Slow is smooth, smooth is fast — commit to the pressure"
            ],
            expectedDiscoveries: [
                "Hip-to-hip connection is the foundation of pressure passing",
                "Head position dictates the direction of the pass",
                "Breaking the guard with hip pressure differs from breaking with arms"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-gp-02",
            name: "Leg Drag Race",
            objective: "Achieve a leg drag position and complete the pass to side control. Score 1 point for leg drag control, 1 additional for completing the pass.",
            skillLevel: .intermediate,
            position: "Passing",
            focusArea: "Guard Passing",
            taskConstraints: [
                "You must initiate from standing only — no knee-in passing",
                "You cannot stall in leg drag — must advance within 5 seconds",
                "Guard player can stand and restart"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Start standing vs. seated guard"
            ],
            individualConstraints: [
                "Stack the hips before you drag the leg"
            ],
            expectedDiscoveries: [
                "The moment the hip turns is when you commit to the drag",
                "High vs. low leg drag changes the back-take opportunity",
                "Upper body position during the drag determines follow-up options"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-gp-03",
            name: "Toreando Touch",
            objective: "Execute a toreando pass to a stable position. Points awarded only when you can touch the mat behind the guard player's head.",
            skillLevel: .intermediate,
            position: "Passing",
            focusArea: "Guard Passing",
            taskConstraints: [
                "You must clear both legs fully to score — partial passes don't count",
                "You may not grab the collar or head during the pass",
                "Bonus point for redirecting a guard recovery into a pass"
            ],
            environmentConstraints: [
                "Round duration: 3 minutes",
                "Start standing vs. seated or open guard"
            ],
            individualConstraints: [
                "The redirect comes from your hips, not your hands"
            ],
            expectedDiscoveries: [
                "Timing the pass with the guard player's weight shift makes it effortless",
                "The angle of the hip push determines which side to finish on",
                "Faking one direction before committing increases success rate"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-gp-04",
            name: "Stack & Crack",
            objective: "Pass using the stack technique against flexible open guard. Score 1 point per completed pass, 2 penalty points if guard player sweeps you.",
            skillLevel: .beginner,
            position: "Passing",
            focusArea: "Guard Passing",
            taskConstraints: [
                "Keep your hips low throughout the pass",
                "You cannot retreat once you begin stacking — commit fully",
                "You must achieve wrist control before initiating the stack"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Guard player uses flexible open guard only"
            ],
            individualConstraints: [
                "Stack until you feel their weight shift — then crack to the side"
            ],
            expectedDiscoveries: [
                "Hip angle while stacking creates or closes back-take opportunities",
                "Wrist control location changes which direction is safer to finish",
                "Stacking high vs. low changes the submission threat level"
            ]
        ),
        CLAGameModel(
            gameId: "builtin-gp-05",
            name: "X-Pass Combinations",
            objective: "String together two different passing techniques in one continuous sequence. Score only for pass completions using a combo — single-pass scores don't count.",
            skillLevel: .advanced,
            position: "Passing",
            focusArea: "Guard Passing",
            taskConstraints: [
                "Each sequence must include at least two distinct passing techniques",
                "You cannot use the same technique twice in the same round",
                "If you stop moving for more than 3 seconds you must reset"
            ],
            environmentConstraints: [
                "Round duration: 5 minutes",
                "Guard player uses dynamic open guard with active sweeping"
            ],
            individualConstraints: [
                "Flow between attacks — your partner's reaction is your invitation"
            ],
            expectedDiscoveries: [
                "The second pass should exploit the reaction to the first",
                "Transitions are faster when you stay on your toes",
                "Feinting sets up the real attack more reliably than power"
            ]
        )
    ]
}
