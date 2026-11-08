import SwiftUI

struct ShowSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                GeometryReader { geo in
                    let size = geo.size

                    Text("\(Int(size.width))×\(Int(size.height)) pt")
                        .font(.caption2.monospacedDigit())
                        .lineLimit(1)
                        .fixedSize()
                        .padding(4)
                        .background(.black.opacity(0.7))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(4)
                }
                .allowsHitTesting(false)
            }
    }
}

extension View {
    func showSize() -> some View {
        self.modifier(ShowSizeModifier())
    }
}
