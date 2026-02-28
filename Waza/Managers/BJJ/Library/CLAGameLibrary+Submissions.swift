import Foundation

extension CLAGameLibrary {

    // MARK: - Submissions

    static let submissionGames: [CLAGameModel] = [
        CLAGameModel(
            gameId: "builtin-su-01",
            name: "Triangle Hunt",
            objective: "Set up and finish triangles from any guard position. Score 1 point per solid triangle lock, 3 points per finish.",
            skillLevel: .intermediate,
            position: "Submissions",
            focusArea: "Triangle Choke",
            taskConstraints: [
                "You may only attack triangles — no other submissions",
                "You must achieve a proper figure-four leg lock to score 1 point",
                "Bonus point for cutting the angle correctly after locking"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Start from closed or open guard"
            ],
            individualConstraints: [
                "Pull the head down before you squeeze — every time"
            ],
            expectedDiscoveries: [
                "Arm position of the target arm determines lock quality",
                "Hip angle dramatically changes the squeeze angle",
                "Breaking posture is the setup, not the afterthought"
            ],
            safetyNotes: "Tap early — neck cranks can occur if the lock is misaligned. Communicate."
        ),
        CLAGameModel(
            gameId: "builtin-su-02",
            name: "Armbar Factory",
            objective: "Attack armbars from any top or guard position. Score 1 point per controlled arm isolation, 3 points per tap.",
            skillLevel: .beginner,
            position: "Submissions",
            focusArea: "Armbar",
            taskConstraints: [
                "You may only finish with armbar — no other techniques",
                "You must control the wrist before extending",
                "Bonus point for transitioning from guard armbar to mounted armbar"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Can start from any position"
            ],
            individualConstraints: [
                "Both hips down on the arm — not just one"
            ],
            expectedDiscoveries: [
                "The grip break often reveals the straight armbar",
                "Mount armbar needs the far knee to block the roll before finishing",
                "Guard armbar hip angle is the most common error point"
            ],
            safetyNotes: "Tap before the elbow is fully hyperextended. Extend slowly when applying."
        ),
        CLAGameModel(
            gameId: "builtin-su-03",
            name: "Rear Naked Hunt",
            objective: "Achieve back control and finish with the rear naked choke. Score 1 point for back control with hooks, 2 for seat belt, 3 for tap.",
            skillLevel: .intermediate,
            position: "Submissions",
            focusArea: "Rear Naked Choke",
            taskConstraints: [
                "You must achieve double hooks before attempting the choke",
                "You cannot use a bow-and-arrow choke — only rear naked",
                "Bonus point for taking the back from guard rather than a scramble"
            ],
            environmentConstraints: [
                "Round duration: 5 minutes",
                "Start from any position"
            ],
            individualConstraints: [
                "The choke hand goes to the shoulder, then slides to the neck"
            ],
            expectedDiscoveries: [
                "Seat belt establishment determines which hook goes in first",
                "The body triangle provides security when hooks are threatened",
                "Chin-strapping blocks neck protection and sets up the choke"
            ],
            safetyNotes: "Tap early — blood chokes cause unconsciousness within seconds."
        ),
        CLAGameModel(
            gameId: "builtin-su-04",
            name: "Kimura Trap",
            objective: "Set up and finish kimura locks from any position. Score per quality lock and finish.",
            skillLevel: .beginner,
            position: "Submissions",
            focusArea: "Kimura",
            taskConstraints: [
                "You must achieve the figure-four grip before rotating the arm",
                "You cannot use the kimura as a sweep without attempting the submission first",
                "Bonus point for connecting a failed kimura directly to a guard sweep"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Can start from any position"
            ],
            individualConstraints: [
                "Lock the grip, then move your body — not your arms — to rotate"
            ],
            expectedDiscoveries: [
                "The kimura from guard can sweep before submitting",
                "North-south kimura works from a position that feels vulnerable",
                "Connecting the elbow to your body multiplies your leverage"
            ],
            safetyNotes: "Stop at resistance — shoulder joints are vulnerable. Tap early."
        ),
        CLAGameModel(
            gameId: "builtin-su-05",
            name: "Guillotine or Bust",
            objective: "Set up and finish guillotine chokes (any variation) from guard, standing, or scramble. Score 1 point per clean lock, 3 per tap.",
            skillLevel: .intermediate,
            position: "Submissions",
            focusArea: "Guillotine Choke",
            taskConstraints: [
                "You may only attack guillotines — no other submissions",
                "You must achieve a clean neck entry before attempting to close guard",
                "Bonus point for finishing from a standing position"
            ],
            environmentConstraints: [
                "Round duration: 4 minutes",
                "Start from standing or clinch"
            ],
            individualConstraints: [
                "Squeeze the elbow across your center line before applying pressure"
            ],
            expectedDiscoveries: [
                "Arm-in vs. arm-out changes the finishing mechanic entirely",
                "Pulling the head into your chest is more effective than squeezing alone",
                "High-elbow guillotine has different body mechanics than the standard"
            ],
            safetyNotes: "Neck crank risk increases when the head is twisted. Keep chin pressure forward."
        )
    ]
}
