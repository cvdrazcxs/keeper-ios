import SwiftUI

public struct HintTailParameters: Sendable {
    public var horizontalOffset: CGFloat
    public var size: CGSize
    public var tailCornerRadius: CGFloat

    public init(
        horizontalOffset: CGFloat,
        size: CGSize,
        tailCornerRadius: CGFloat
    ) {
        self.horizontalOffset = horizontalOffset
        self.size = size
        self.tailCornerRadius = tailCornerRadius
    }
}
