import Foundation

public struct BannerItem {
    public var id: String
    public var title: String
    public var description: String
    public var actionTitle: String
    public var imageURL: URL?
    public var action: (() -> Void)?

    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String = "",
        actionTitle: String,
        imageURL: URL? = nil,
        action: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.imageURL = imageURL
        self.action = action
    }
}
