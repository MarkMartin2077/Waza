import SwiftUI

// MARK: - Staggered Appear

/// Fades and slides content in on first appearance with an index-based delay.
struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    let delay: Double

    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .onAppear {
                withAnimation(.easeOut(duration: 0.35).delay(Double(index) * delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Scale Appear

/// Scales and fades content in on first appearance.
struct ScaleAppearModifier: ViewModifier {
    let delay: Double

    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.92)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Animated Counter Text

/// Displays an integer that counts up/down with a numeric text transition.
struct AnimatedCounterText: View {
    let value: Int
    let font: Font
    let foregroundStyle: AnyShapeStyle

    init(_ value: Int, font: Font = .title3, foregroundStyle: some ShapeStyle = .primary) {
        self.value = value
        self.font = font
        self.foregroundStyle = AnyShapeStyle(foregroundStyle)
    }

    var body: some View {
        Text("\(value)")
            .font(font)
            .foregroundStyle(foregroundStyle)
            .contentTransition(.numericText(value: Double(value)))
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
    }
}

// MARK: - View Extensions

extension View {

    /// Staggered fade + slide entrance for list items.
    func staggeredAppear(index: Int, delay: Double = 0.05) -> some View {
        modifier(StaggeredAppearModifier(index: index, delay: delay))
    }

    /// Scale + fade entrance for cards and sections.
    func scaleAppear(delay: Double = 0) -> some View {
        modifier(ScaleAppearModifier(delay: delay))
    }
}
