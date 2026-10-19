import XCTest
@testable import DreameCore

final class CredentialAccountTests: XCTestCase {
    func testLegacyCredentialsDefaultToDreame() throws {
        let saved = try JSONDecoder().decode(StoredCredentials.self, from: Data(#"{"username":"test","password":"fixture","region":"sg"}"#.utf8))
        XCTAssertEqual(saved.account, .dreame)
    }
    func testMovaCredentialsRoundTrip() throws {
        let saved = StoredCredentials(username:"test",password:"fixture",region:"eu",account:.mova)
        let decoded = try JSONDecoder().decode(StoredCredentials.self,from:JSONEncoder().encode(saved))
        XCTAssertEqual(decoded.account,.mova)
        XCTAssertTrue(decoded.matches(username:"test",region:"eu",account:.mova))
        XCTAssertFalse(decoded.matches(username:"test",region:"eu",account:.dreame))
        XCTAssertFalse(decoded.matches(username:"test",region:"us",account:.mova))
        XCTAssertFalse(decoded.matches(username:"other",region:"eu",account:.mova))
    }
    func testUnknownAccountDoesNotFallbackToDreame() {
        XCTAssertThrowsError(try JSONDecoder().decode(StoredCredentials.self,from:Data(#"{"username":"test","password":"fixture","region":"sg","account":"unknown"}"#.utf8)))
    }
}
