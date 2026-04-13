import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let direction: CGSize
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let startRotation: Double
    let endRotation: Double
    let delay: Double
}

struct ConfettiView: View {
    let colors: [Color]

    @State private var particles: [ConfettiParticle] = []
    @State private var launched = false

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                RoundedRectangle(cornerRadius: 2)
                    .fill(particle.color)
                    .frame(width: particle.width, height: particle.height)
                    .rotationEffect(.degrees(launched ? particle.endRotation : particle.startRotation))
                    .offset(launched ? particle.direction : .zero)
                    .opacity(launched ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.05).delay(particle.delay),
                        value: launched
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            particles = makeParticles()
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 60_000_000)
                launched = true
            }
        }
    }

    private func makeParticles() -> [ConfettiParticle] {
        (0..<50).map { _ in
            let angle = Double.random(in: -.pi...(.pi))
            let distance = CGFloat.random(in: 160...380)
            let startRotation = Double.random(in: 0..<360)
            return ConfettiParticle(
                direction: CGSize(
                    width: cos(angle) * distance,
                    height: sin(angle) * distance + CGFloat.random(in: 50...130)
                ),
                color: colors.randomElement() ?? .white,
                width: CGFloat.random(in: 7...14),
                height: CGFloat.random(in: 3...5),
                startRotation: startRotation,
                endRotation: startRotation + Double.random(in: 90...270),
                delay: Double.random(in: 0...0.08)
            )
        }
    }
}
