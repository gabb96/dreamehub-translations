import XCTest
import Foundation
@testable import DreameCore
@_silgen_name("compress2") private func refreshCompress(_ dst:UnsafeMutablePointer<UInt8>,_ length:UnsafeMutablePointer<UInt>,_ src:UnsafePointer<UInt8>,_ count:UInt,_ level:Int32)->Int32

private final class RefreshClock: @unchecked Sendable {
    private let lock=NSLock()
    private var value=Date(timeIntervalSince1970:1_800_000_000)
    func read()->Date { lock.lock();defer{lock.unlock()};return value }
    func advance(_ seconds:Double) { lock.lock();defer{lock.unlock()};value.addTimeInterval(seconds) }
}
private actor RefreshSource {
    var frames:[String]
    var updates:JSONValue = .array([])
    var captures=0
    var histories=0
    var fail=false
    var held=false
    var continuation:CheckedContinuation<Void,Never>?
    init(_ frames:[String]) { self.frames=frames }
    func setUpdates(_ raws:[String]) { updates = .array(raws.enumerated().map { .object(["time":.integer($0.offset),"value":.string($0.element)]) }) }
    func setFailure() { fail=true }
    func hold() { held=true }
    func release() { continuation?.resume();continuation=nil }
    func capture(_ device:CloudDevice) async throws -> MapService.Capture {
        captures += 1
        let raw=frames[min(captures-1,frames.count-1)]
        if held { held=false;await withCheckedContinuation { continuation=$0 } }
        if fail { throw URLError(.notConnectedToInternet) }
        return .init(raw:raw,iv:nil,key:nil,version:1,source:"offline_fixture")
    }
    func history(_ device:CloudDevice,_ from:Int)->JSONValue { histories += 1;return updates }
}

final class MapServiceTests:XCTestCase {
    private func device(_ id:String="one") throws -> CloudDevice {
        try CloudDevice(raw:.object(["did":.string(id),"model":.string("dreame.vacuum.p2008")]))
    }
    private func frame(_ id:Int16,_ time:Int64=1_700_000_000_000,kind:UInt8=73) throws -> String {
        var raw=[UInt8](repeating:0,count:27)
        func put(_ at:Int,_ value:Int16) { let n=UInt16(bitPattern:value);raw[at]=UInt8(n&255);raw[at+1]=UInt8(n>>8) }
        put(0,7);put(2,id);raw[4]=kind;put(5,id);put(7,200);put(9,359)
        put(11,32767);put(13,32767);put(15,32767);put(17,50);put(19,2);put(21,2);put(23,-500);put(25,-300)
        let data=Data(raw+[4,0,0,0])+(try JSONSerialization.data(withJSONObject:["fsm":1,"timestamp_ms":time]))
        var out=[UInt8](repeating:0,count:data.count+1024),length=UInt(data.count+1024)
        let result=data.withUnsafeBytes { refreshCompress(&out,&length,$0.bindMemory(to:UInt8.self).baseAddress!,UInt(data.count),6) }
        XCTAssertEqual(result,0)
        return Data(out.prefix(Int(length))).base64EncodedString()
    }
    private func service(_ source:RefreshSource,_ clock:RefreshClock=RefreshClock())->MapService {
        MapService(now:{clock.read()},capture:{try await source.capture($0)},history:{await source.history($0,$1)})
    }
    func testDuplicateAndOldFramesNeverChangeCaptureTime() async throws {
        let source=RefreshSource([try frame(9)]),clock=RefreshClock(),service=service(source,clock)
        let first=try await service.current(device:device())
        await source.setUpdates([try frame(9),try frame(8),try frame(10,1_699_000_000_000,kind:80)])
        clock.advance(3)
        let next=try await service.current(device:device())
        XCTAssertEqual(next["frame_id"].int,9)
        XCTAssertEqual(next["timestamp_ms"],first["timestamp_ms"])
        XCTAssertEqual(next["telemetry"]["freshness_ms"].int,first["telemetry"]["freshness_ms"].int!+3000)
        XCTAssertNil(next["update_warning"].string)
    }
    func testFullFailureKeepsLastValidAndStillAppliesHistory() async throws {
        let source=RefreshSource([try frame(9)]),clock=RefreshClock(),service=service(source,clock)
        _=try await service.current(device:device())
        await source.setFailure();clock.advance(11)
        var next=try await service.current(device:device())
        XCTAssertEqual(next["frame_id"].int,9);XCTAssertNotNil(next["update_warning"].string)
        await source.setUpdates([try frame(10,1_700_000_001_000,kind:80)])
        next=try await service.current(device:device())
        XCTAssertEqual(next["frame_id"].int,10)
    }
    func testMissingChainRecoversFullAndRetriesDelta() async throws {
        let source=RefreshSource([try frame(9),try frame(10,1_700_000_001_000)]),service=service(source)
        _=try await service.current(device:device())
        await source.setUpdates([try frame(11,1_700_000_002_000,kind:80)])
        let next=try await service.current(device:device())
        XCTAssertEqual(next["frame_id"].int,11);XCTAssertEqual(next["incremental_verified_chain"].bool,true)
        XCTAssertNil(next["update_warning"].string)
    }
    func testMissingChainWithoutNewBaseKeepsValidFrame() async throws {
        let source=RefreshSource([try frame(9)]),service=service(source)
        _=try await service.current(device:device())
        await source.setUpdates([try frame(11,1_700_000_002_000,kind:80)])
        let next=try await service.current(device:device())
        XCTAssertEqual(next["frame_id"].int,9);XCTAssertNotNil(next["update_warning"].string)
    }
    func testPeriodicFullCannotRewindButEqualTimestampNewFrameCanAdvance() async throws {
        let source=RefreshSource([try frame(9),try frame(8,1_699_000_000_000),try frame(10)]),clock=RefreshClock(),service=service(source,clock)
        _=try await service.current(device:device())
        clock.advance(11)
        let old=try await service.current(device:device())
        XCTAssertEqual(old["frame_id"].int,9)
        clock.advance(11)
        let next=try await service.current(device:device())
        XCTAssertEqual(next["frame_id"].int,10)
        XCTAssertEqual(next["timestamp_ms"].int,1_700_000_000_000)
    }
    func testRecoveryDownloadFailureDoesNotDiscardLastGoodMap() async throws {
        let source=RefreshSource([try frame(9)]),service=service(source)
        _=try await service.current(device:device())
        await source.setFailure()
        await source.setUpdates([try frame(11,1_700_000_002_000,kind:80)])
        let next=try await service.current(device:device())
        XCTAssertEqual(next["frame_id"].int,9)
        XCTAssertEqual(next["acquisition_source"].string,"offline_fixture")
        XCTAssertNotNil(next["update_warning"].string)
    }
    func testInitialFailureDoesNotInventMap() async throws {
        let source=RefreshSource([try frame(9)]),service=service(source)
        await source.setFailure()
        do { _=try await service.current(device:device());XCTFail("No real map available") }
        catch let error as URLError { XCTAssertEqual(error.code,.notConnectedToInternet) }
    }
    func testOverlappingPollsShareOneAcquisition() async throws {
        let source=RefreshSource([try frame(9)]),service=service(source)
        await source.hold()
        let d=try device()
        let first=Task { try await service.current(device:d) }
        while await source.captures == 0 { await Task.yield() }
        let second=Task { try await service.current(device:d) }
        await source.release()
        let a=try await first.value,b=try await second.value
        XCTAssertEqual(a["frame_id"],b["frame_id"])
        let count=await source.captures;XCTAssertEqual(count,1)
    }
    func testOldDeviceResponseCannotOverwriteNewDevice() async throws {
        let source=RefreshSource([try frame(9),try frame(20)]),service=service(source)
        await source.hold()
        let old=try device("old"),new=try device("new")
        let first=Task { try await service.current(device:old) }
        while await source.captures == 0 { await Task.yield() }
        let newest=try await service.current(device:new)
        await source.release()
        do { _=try await first.value;XCTFail("Superseded device response accepted") } catch is CancellationError {}
        let retained=try await service.current(device:new)
        XCTAssertEqual(newest["frame_id"].int,20);XCTAssertEqual(retained["frame_id"].int,20)
    }
}
