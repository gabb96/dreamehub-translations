import XCTest
import Foundation
@testable import DreameCore
@_silgen_name("compress2") private func mapFixtureCompress(_ dst:UnsafeMutablePointer<UInt8>,_ length:UnsafeMutablePointer<UInt>,_ src:UnsafePointer<UInt8>,_ count:UInt,_ level:Int32)->Int32

final class MapDecoderTests: XCTestCase {
    private func packed(_ data:Data) throws -> String {
        var out=[UInt8](repeating:0,count:data.count+1024),length=UInt(data.count+1024)
        let status=data.withUnsafeBytes { p in mapFixtureCompress(&out,&length,p.bindMemory(to:UInt8.self).baseAddress!,UInt(data.count),6) }
        XCTAssertEqual(status,0)
        return Data(out.prefix(Int(length))).base64EncodedString()
    }
    private func frame(_ metadata:[String:Any]=[:], pixels:[UInt8]=[4,4,252,8], kind:UInt8=73, id:Int16=9) throws -> Data {
        var raw=[UInt8](repeating:0,count:27)
        func put(_ at:Int,_ value:Int16) { let n=UInt16(bitPattern:value);raw[at]=UInt8(n&255);raw[at+1]=UInt8(n>>8) }
        put(0,7);put(2,id);raw[4]=kind;put(5,-100);put(7,200);put(9,359)
        put(11,32767);put(13,32767);put(15,32767);put(17,50);put(19,2);put(21,2);put(23,-500);put(25,-300)
        return Data(raw+pixels)+(try JSONSerialization.data(withJSONObject:metadata))
    }
    func testFullFrame() throws {
        let m=try MapDecoder.decodeInflated(frame(["fsm":1,"tr":"M-100,200L50,-50S10,20L10,0"]))
        XCTAssertEqual(m["robot_position"] as? [Int],[-100,200,359]);XCTAssertTrue(m["charger_position"] is NSNull)
        XCTAssertEqual((m["data"] as? [String:[Int]])?["1"],[0,0,2])
        XCTAssertEqual((m["data"] as? [String:[Int]])?["255"],[0,1,1])
        XCTAssertEqual(m["path"] as? [[Int]],[[3,-100,200,-50,150],[1,10,20,20,20]])
        XCTAssertNoThrow(try JSONSerialization.data(withJSONObject:m))
    }
    func testNoFakeSensorMeasurements() throws {
        let m=try MapDecoder.decodeInflated(frame(["laser_obstacle":[[3,4,128]]]))
        let t=try XCTUnwrap(m["telemetry"] as? [String:Any])
        XCTAssertEqual(t["simulated"] as? [String],[])
        XCTAssertTrue(t["observed_at"] is NSNull)
        XCTAssertTrue(t["freshness_ms"] is NSNull)
        XCTAssertTrue((m["laser_obstacles"] as! [[Any]])[0][3] is NSNull)
        XCTAssertEqual((t["capabilities"] as? [String:Bool])?["raw_lidar_rays"],false)
    }
    func testInvalidAndUnsupportedFrames() throws {
        XCTAssertThrowsError(try MapDecoder.decodeInflated(Data([1,2])))
        XCTAssertThrowsError(try MapDecoder.decodeInflated(frame(kind:80)))
        XCTAssertThrowsError(try MapDecoder.decode("not_base64"))
    }
    func testOrderedDeltaAdditionAndPath() throws {
        let s=MapStreamDecoder()
        _=try s.acceptInflated(frame(["fsm":1,"tr":"M1,2L1,1"]))
        let m=try s.acceptInflated(frame(["tr":"l3,4L1,0","timestamp_ms":1792070000000],pixels:[4,0,0,0],kind:80,id:10))
        XCTAssertEqual((m["data"] as? [String:[Int]])?["2"],[0,0,1,1,1,1])
        XCTAssertEqual(m["path"] as? [[Int]],[[3,1,2,2,3,3,4,4,4]])
        XCTAssertEqual(m["frame_type"] as? String,"P")
        XCTAssertEqual(m["incremental_verified_chain"] as? Bool,true)
    }
    func testMissingPredecessorRejectedWithoutChangingBase() throws {
        let s=MapStreamDecoder()
        _=try s.acceptInflated(frame(["fsm":1]))
        XCTAssertThrowsError(try s.acceptInflated(frame(pixels:[4,0,0,0],kind:80,id:11)))
        XCTAssertNoThrow(try s.acceptInflated(frame(pixels:[4,0,0,0],kind:80,id:10)))
    }
    func testKnownModelMetadataAndUnknownModel() {
        XCTAssertEqual(MapService.configuration(model:"dreame.vacuum.r2338a")?.iv?.count,16)
        XCTAssertNil(MapService.configuration(model:"unknown.vacuum.no_such_model"))
    }
    func testNestedSavedMapComposesCleaningLayer() throws {
        let saved=try packed(frame([:],pixels:[1,2,128,3]))
        let result=try MapDecoder.decodeInflated(frame(["ris":2,"rism":saved],pixels:[0,2,1,0]))
        let layers=try XCTUnwrap(result["data"] as? [String:[Int]])
        XCTAssertEqual(layers["1"],[0,0,1]);XCTAssertEqual(layers["255"],[1,0,1])
        XCTAssertEqual(layers["254"],[0,1,1]);XCTAssertEqual(layers["3"],[1,1,1])
        XCTAssertEqual(result["saved_map_id"] as? Int,7)
    }
    func testV3DeltaCoverAndObjectChanges() throws {
        func obstacle(_ id:Int,_ x:Int)->[Any] { [x,2,128,0.9,"100\(id)","file","key",0,0,0,0,2,id,0,0,0,0,0,0] }
        let s=MapStreamDecoder()
        _=try s.acceptInflated(frame(["saveMapId":7,"tr":"M1,2L1,1","ai_obstacle":[obstacle(1,1),obstacle(2,2)]],pixels:[1,1,63,2]),version:3)
        let m=try s.acceptInflated(frame(["cover":["timestamp_ms":1792070000000,"tr":"l3,4L1,0","laser_obstacle":[[5,6,128,0.7]]],"diff":["ai_obstacle":[obstacle(1,9),obstacle(3,3)],"deleteContent":["ai_obstacle":[2]]]],pixels:[2,0,0,0],kind:80,id:10),version:3)
        XCTAssertEqual((m["data"] as? [String:[Int]])?["2"],[0,0,1,1,1,1])
        XCTAssertEqual(m["path"] as? [[Int]],[[3,1,2,2,3,3,4,4,4]])
        let objects=try XCTUnwrap(m["obstacles"] as? [[Any]])
        XCTAssertEqual(objects.count,2);XCTAssertEqual(objects[0][1] as? Double,9)
        XCTAssertEqual(objects[1][7] as? String,"1003")
        XCTAssertEqual(m["timestamp_ms"] as? Int64,1792070000000)
        XCTAssertEqual((m["laser_obstacles"] as? [[Any]])?.count,1)
    }
}
