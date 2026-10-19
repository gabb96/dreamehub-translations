import XCTest
@testable import DreameCore

final class ProductCatalogTests: XCTestCase {
    func testCatalogUsesExactIdentifiersAndNeutralArtwork() {
        let ids = ProductCatalog.entries.flatMap(\.modelIDs)
        XCTAssertEqual(ids.count, 84)
        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertEqual(ProductCatalog.entries.count, 22)
        for entry in ProductCatalog.entries {
            XCTAssertEqual(entry.imagePath, "/assets/products/generic.svg")
            for id in entry.modelIDs { XCTAssertEqual(ProductCatalog.lookup(model:id), entry) }
        }
        XCTAssertNil(ProductCatalog.lookup(model:"mova.vacuum.unknown"))
        XCTAssertNil(ProductCatalog.lookup(model:"mova.vacuum.r2475z"))
    }
    func testGroupedModeRequiresKnownModelAndReportedStation() {
        XCTAssertTrue(ProductCatalog.supportsGroupedCleaning(model:"mova.vacuum.r2475a",hasSelfWashBase:true))
        XCTAssertFalse(ProductCatalog.supportsGroupedCleaning(model:"mova.vacuum.r2475a",hasSelfWashBase:false))
        XCTAssertFalse(ProductCatalog.supportsGroupedCleaning(model:"dreame.vacuum.r2383a",hasSelfWashBase:true))
        XCTAssertFalse(ProductCatalog.supportsGroupedCleaning(model:"mova.vacuum.unknown",hasSelfWashBase:true))
    }
    func testPublicNeutralArtworkExists() throws {
        let root = URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let text = try String(contentsOf:root.appendingPathComponent("Sources/DreameHub/Resources/assets/products/generic.svg"))
        XCTAssertTrue(text.contains("<svg"))
        XCTAssertFalse(text.contains("http://www.mova"))
    }
}
