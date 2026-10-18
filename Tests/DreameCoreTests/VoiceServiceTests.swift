import XCTest
@testable import DreameCore

final class VoiceServiceTests: XCTestCase {
    func testRootTarRoundtripAndAlignment() throws {
        let files = ["0.ogg": Data(repeating: 22, count: 513), "tts.json": Data("{}".utf8)]
        let tar = try VoiceService.makeTar(files)
        XCTAssertEqual(tar.count % 512, 0)
        XCTAssertEqual(try VoiceService.parseTar(tar), files)
    }
    func testUnsafeNamesRejected() throws {
        for name in ["../file.ogg", ".hidden", "dir/file.ogg", "dir\\file.ogg"] {
            XCTAssertThrowsError(try VoiceService.makeTar([name: Data([1])]))
        }
    }
    func testDamagedTarRejected() throws {
        var tar = try VoiceService.makeTar(["0.ogg": Data([1])])
        tar[0] = 88
        XCTAssertThrowsError(try VoiceService.parseTar(tar))
    }
    func testHTTPRanges() throws {
        XCTAssertEqual(try VoiceTransferHost.byteRange(nil, count: 10), 0..<10)
        XCTAssertEqual(try VoiceTransferHost.byteRange("bytes=2-4", count: 10), 2..<5)
        XCTAssertEqual(try VoiceTransferHost.byteRange("bytes=2-", count: 10), 2..<10)
        XCTAssertEqual(try VoiceTransferHost.byteRange("bytes=-3", count: 10), 7..<10)
        XCTAssertEqual(try VoiceTransferHost.byteRange("bytes=0-9999", count: 10), 0..<10)
        XCTAssertThrowsError(try VoiceTransferHost.byteRange("bytes=10-", count: 10))
        XCTAssertThrowsError(try VoiceTransferHost.byteRange("bytes=0-2,4-5", count: 10))
        XCTAssertThrowsError(try VoiceTransferHost.byteRange("bytes=-0", count: 10))
    }
    func testManifestModelValidation() throws {
        XCTAssertThrowsError(try VoiceService(model: "../arbitrary"))
        XCTAssertNoThrow(try VoiceService(model: "dreame.vacuum.r2338a"))
    }
    func testPublicAddressNotAcceptedForTransfer() throws {
        XCTAssertThrowsError(try VoiceTransferHost(payload: Data([1]), peerIP: "8.8.8.8"))
        XCTAssertThrowsError(try VoiceTransferHost(payload: Data(), peerIP: "127.0.0.1"))
    }
}
