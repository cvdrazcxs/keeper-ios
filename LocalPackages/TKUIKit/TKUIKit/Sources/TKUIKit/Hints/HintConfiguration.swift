import UIKit

public enum HintAnimationStyle {
    case bouncing
}

public struct HintConfiguration {
    public var position: HintPosition
    public var maximumWidth: CGFloat
    public var animationStyle: HintAnimationStyle

    public init(
        position: HintPosition,
        maximumWidth: CGFloat = 200,
        animationStyle: HintAnimationStyle
    ) {
        self.position = position
        self.maximumWidth = maximumWidth
        self.animationStyle = animationStyle
    }
}
