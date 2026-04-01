import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var xPos: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if xPos + size.width > width, xPos > 0 {
                height += rowHeight + spacing
                xPos = 0
                rowHeight = 0
            }
            xPos += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var xPos = bounds.minX
        var yPos = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if xPos + size.width > bounds.maxX, xPos > bounds.minX {
                yPos += rowHeight + spacing
                xPos = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: xPos, y: yPos), proposal: ProposedViewSize(size))
            xPos += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
