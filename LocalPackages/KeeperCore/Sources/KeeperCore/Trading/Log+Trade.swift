import TKLogging

public extension LogDomain {
    static var trade: LogDomain {
        LogDomain(category: "Trade")
    }
}

public extension Log {
    static var trade: LogDomain {
        .trade
    }
}
