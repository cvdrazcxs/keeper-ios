@testable import App
import XCTest

final class HistoryListItemsTests: XCTestCase {
    func test_uniqueEventSnapshotItems_skipsDuplicateIdentifiersAcrossSections() {
        var seenIdentifiers = Set<HistoryList.EventID>()

        let firstSectionItems = HistoryList.uniqueEventSnapshotItems(
            identifiers: ["ton-1", "ton-2"],
            seenIdentifiers: &seenIdentifiers
        )
        let secondSectionItems = HistoryList.uniqueEventSnapshotItems(
            identifiers: ["ton-2", "tron-1", "ton-1"],
            seenIdentifiers: &seenIdentifiers
        )

        XCTAssertEqual(
            firstSectionItems,
            [.event("ton-1"), .event("ton-2")]
        )
        XCTAssertEqual(
            secondSectionItems,
            [.event("tron-1")]
        )
    }
}
