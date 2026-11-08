import SwiftUI

public extension Cell {
    init(
        config: Config = Config(),
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder center: () -> Center,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(
            config: config,
            leading: leading(),
            center: center(),
            trailing: trailing()
        )
    }
}

public extension Cell where Leading == EmptyView, Trailing == EmptyView {
    init(
        config: Config = Config(),
        @ViewBuilder center: () -> Center
    ) {
        self.init(
            config: config,
            leading: EmptyView(),
            center: center(),
            trailing: EmptyView()
        )
    }
}

public extension Cell where Trailing == EmptyView {
    init(
        config: Config = Config(),
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder center: () -> Center
    ) {
        self.init(
            config: config,
            leading: leading(),
            center: center(),
            trailing: EmptyView()
        )
    }
}

public extension Cell where Leading == EmptyView {
    init(
        config: Config = Config(),
        @ViewBuilder center: () -> Center,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(
            config: config,
            leading: EmptyView(),
            center: center(),
            trailing: trailing()
        )
    }
}
