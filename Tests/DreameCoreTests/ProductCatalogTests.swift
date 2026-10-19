import XCTest
import AppKit
@testable import DreameCore

final class ProductCatalogTests: XCTestCase {
    func testEveryExactIdentifierResolvesUniquely() {
        let ids = ProductCatalog.entries.flatMap(\.modelIDs)
        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertEqual(ProductCatalog.entries.count, 22)
        for entry in ProductCatalog.entries {
            for id in entry.modelIDs { XCTAssertEqual(ProductCatalog.lookup(model: id), entry) }
        }
    }

    func testKnownNamesAndNoGuessing() {
        XCTAssertEqual(ProductCatalog.lookup(model: "mova.vacuum.r2475a")?.name, "MOVA P50 Pro Ultra")
        XCTAssertEqual(ProductCatalog.lookup(model: "dreame.vacuum.r2427")?.name, "MOVA E30 Ultra")
        XCTAssertEqual(ProductCatalog.lookup(model: "mova.vacuum.r2582h")?.name, "MOVA V50 Ultra Complete")
        for unknown in ["", "mova.vacuum.r2475", "mova.vacuum.r2475z", "dreame.vacuum.r2475a", "mova.vacuum.future", "dreame.vacuum.r2338a"] {
            XCTAssertNil(ProductCatalog.lookup(model: unknown))
        }
    }

    func testEveryBundledImageIsPNGWithTransparentPixels() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        for path in Set(ProductCatalog.entries.map(\.imagePath)) {
            let url = root.appendingPathComponent("Sources/DreameHub/Resources" + path)
            let data = try Data(contentsOf: url)
            XCTAssertEqual(Array(data.prefix(8)), [137, 80, 78, 71, 13, 10, 26, 10], path)
            let image = try XCTUnwrap(NSBitmapImageRep(data: data), path)
            XCTAssertTrue(image.hasAlpha, path)
            XCTAssertGreaterThanOrEqual(image.pixelsWide, 600, path)
            XCTAssertGreaterThanOrEqual(image.pixelsHigh, 600, path)
            XCTAssertLessThan(image.colorAt(x: 0, y: 0)?.alphaComponent ?? 1, 0.01, path)
        }
    }

    func testVerifiedGroupedEncodingRequiresReportedBase() {
        XCTAssertEqual(VerifiedMovaCapabilities.groupedCleaningModelIDs.count, 78)
        for model in VerifiedMovaCapabilities.groupedCleaningModelIDs {
            XCTAssertNotNil(ProductCatalog.lookup(model: model))
            XCTAssertTrue(VerifiedMovaCapabilities.supportsGroupedCleaning(model: model, hasSelfWashBase: true))
            XCTAssertFalse(VerifiedMovaCapabilities.supportsGroupedCleaning(model: model, hasSelfWashBase: false))
        }
        for excluded in ["dreame.vacuum.r2459a", "dreame.vacuum.r2459h", "dreame.vacuum.r2459k", "dreame.vacuum.r2380", "dreame.vacuum.r2383a", "dreame.vacuum.r2383k", "mova.vacuum.future"] {
            XCTAssertFalse(VerifiedMovaCapabilities.supportsGroupedCleaning(model: excluded, hasSelfWashBase: true))
        }
    }
}
