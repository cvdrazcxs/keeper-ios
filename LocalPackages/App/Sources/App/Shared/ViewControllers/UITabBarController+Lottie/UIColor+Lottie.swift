import Lottie
import UIKit

extension UIColor {
    var asLottieColor: LottieColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return LottieColor(
            r: Double(red),
            g: Double(green),
            b: Double(blue),
            a: Double(alpha)
        )
    }
}
