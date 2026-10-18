import XCTest
@testable import DreameCore

final class DeviceContractTests: XCTestCase {
    func testGroupedSettingsPreserveOtherFields() throws {
        let original = (2 << 16) | (7 << 8) | 2
        XCTAssertEqual(try DeviceContract.updatedGrouped(original, mode:2), (2 << 16) | (7 << 8))
        XCTAssertEqual(try DeviceContract.updatedGrouped(original, water:3), (3 << 16) | (7 << 8) | 2)
    }
    func testInvalidValuesRejected() {
        XCTAssertThrowsError(try DeviceContract.updatedGrouped(0, water:4))
        XCTAssertThrowsError(try DeviceContract.action("unknown", deviceID:"test"))
    }
    func testNoFalseSuccess() {
        XCTAssertThrowsError(try DeviceContract.requireAcknowledgement([] as [[String:Any]]))
        XCTAssertThrowsError(try DeviceContract.requireAcknowledgement(["message":"OK"]))
        XCTAssertThrowsError(try DeviceContract.requireAcknowledgement([["code":-1]]))
        XCTAssertNoThrow(try DeviceContract.requireAcknowledgement([["code":0]]))
    }
    func testPropertyDoesNotUseErrorValue() {
        XCTAssertNil(DeviceContract.property([["siid":3,"piid":1,"value":100,"code":-1]],3,1))
        XCTAssertNil(DeviceContract.property([["siid":3,"piid":1,"value":100]],3,1))
        XCTAssertEqual(DeviceContract.property([["siid":3,"piid":1,"value":100],["siid":3,"piid":1,"value":87,"code":0]],3,1) as? Int,87)
    }
    func testActionContract() throws {
        let wash = try DeviceContract.action("wash", deviceID:"test")
        XCTAssertEqual(wash["siid"] as? Int,4)
        XCTAssertEqual((wash["in"] as? [[String:Any]])?.first?["value"] as? String,"2,1")
    }
}
