import XCTest
import CryptoKit
@testable import DreameCore

final class CloudMockProtocol: URLProtocol, @unchecked Sendable {
    static var handler: ((URLRequest) throws -> (Int,Data))?
    override class func canInit(with request:URLRequest) -> Bool { true }
    override class func canonicalRequest(for request:URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (status,data) = try Self.handler!(request)
            client?.urlProtocol(self,didReceive:HTTPURLResponse(url:request.url!,statusCode:status,httpVersion:nil,headerFields:nil)!,cacheStoragePolicy:.notAllowed)
            client?.urlProtocol(self,didLoad:data); client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self,didFailWithError:error) }
    }
    override func stopLoading() {}
}

final class CloudClientTests:XCTestCase {
    func testMovaStateUsesCatalogAndReportedPackedModeWithoutInventingWetness() async throws {
        var rawMode = (2 << 16) | 2
        CloudMockProtocol.handler = { [auth] request in
            XCTAssertEqual(request.url?.host, "us.iot.mova-tech.com")
            if request.url!.path.contains("oauth") { return (200, Data(auth.utf8)) }
            if request.url!.path.hasSuffix("listV2") {
                return (200, Data(#"{"code":0,"data":{"page":{"records":[{"did":"1","model":"mova.vacuum.r2475a"}]}}}"#.utf8))
            }
            return (200, Data("{\"code\":0,\"data\":{\"result\":[{\"siid\":4,\"piid\":25,\"code\":0,\"value\":0},{\"siid\":4,\"piid\":23,\"code\":0,\"value\":\(rawMode)}]}}".utf8))
        }
        let service = DeviceService(cloud:client())
        try await service.login(username:"test",password:"test",region:"us",remember:false,account:.mova)
        var state = await service.publicState()
        var device = try XCTUnwrap(state["device"] as? [String:Any])
        XCTAssertEqual(device["name"] as? String,"MOVA P50 Pro Ultra")
        XCTAssertEqual(device["image_url"] as? String,"/assets/products/generic.svg")
        XCTAssertEqual(device["cleaning_mode"] as? Int,0)
        XCTAssertEqual(device["water"] as? Int,2)
        XCTAssertFalse(GoToController.supports(model:"mova.vacuum.r2475a"))
        rawMode = (16 << 16) | 2
        try await service.refresh()
        state = await service.publicState(); device = try XCTUnwrap(state["device"] as? [String:Any])
        XCTAssertTrue(device["water"] is NSNull)
        do { try await service.setting("water",value:2); XCTFail("Unknown wetness scale must not be overwritten") }
        catch DeviceService.ServiceError.unsupported {}
    }
    func testMovaAccountRoutingSigningAndReturnToDreame() async throws {
        var provider = CloudAccount.mova
        var calls = 0
        CloudMockProtocol.handler = { [auth] request in
            calls += 1
            XCTAssertEqual(request.url?.host, provider == .mova ? "us.iot.mova-tech.com" : "us.iot.dreame.tech")
            XCTAssertEqual(request.value(forHTTPHeaderField: "tenant-id"), provider.tenant)
            XCTAssertEqual(request.value(forHTTPHeaderField: "authorization"), provider.authorization)
            XCTAssertEqual(request.value(forHTTPHeaderField: "dreame-psd"), provider == .mova ? "new" : nil)
            XCTAssertTrue(request.value(forHTTPHeaderField: "dreame-meta")?.hasPrefix("cv=a_\(provider.version);") == true)
            if request.url!.path.contains("oauth") { return (200, Data(auth.utf8)) }
            XCTAssertNotNil(request.value(forHTTPHeaderField: "dreame-rlc"))
            if request.url!.path.hasSuffix("listV2") {
                return (200,Data(#"{"code":0,"data":{"page":{"records":[{"did":"1","model":"mova.vacuum.r2475a"}]}}}"#.utf8))
            }
            var body = request.httpBody ?? Data()
            if body.isEmpty, let stream = request.httpBodyStream {
                stream.open(); defer { stream.close() }
                var bytes = [UInt8](repeating: 0, count: 4096)
                while stream.hasBytesAvailable { let count = stream.read(&bytes, maxLength: bytes.count); if count <= 0 { break }; body.append(bytes, count: count) }
            }
            var payload = try XCTUnwrap(JSONDecoder().decode(JSONValue.self, from: body).object)
            let signature = payload.removeValue(forKey: "sign")?.string
            let timestamp = try XCTUnwrap(payload.removeValue(forKey: "timestamp")?.int)
            let input = try CloudClient.canonicalSignatureInput(payload) + String(timestamp) + provider.clientID
            let expected = Insecure.MD5.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
            XCTAssertEqual(signature, expected)
            return (200, Data(#"{"code":0,"data":{"result":[]}}"#.utf8))
        }
        let cloud = client()
        _ = try await cloud.login(username: "test", password: "test", country: "us", account: .mova)
        let devices = try await cloud.devices()
        XCTAssertEqual(devices.first?.model, "mova.vacuum.r2475a")
        _ = try await cloud.rpc(device: devices[0], method: "get_properties", params: .array([]))
        provider = .dreame
        _ = try await cloud.login(username: "test", password: "test", country: "us")
        XCTAssertEqual(calls, 4)
    }

    func testMovaRefreshStaysOnSelectedProvider() async throws {
        var authCalls = 0
        CloudMockProtocol.handler = { request in
            XCTAssertEqual(request.url?.host, "eu.iot.mova-tech.com")
            XCTAssertEqual(request.value(forHTTPHeaderField: "dreame-psd"), "new")
            if request.url!.path.contains("oauth") {
                authCalls += 1
                return (200, Data("{\"access_token\":\"test\",\"refresh_token\":\"refresh\",\"expires_in\":\(authCalls == 1 ? 0 : 3600),\"uid\":\"1\"}".utf8))
            }
            return (200, Data(#"{"code":0,"data":{"page":{"records":[]}}}"#.utf8))
        }
        let cloud = client()
        _ = try await cloud.login(username: "test", password: "test", country: "eu", account: .mova)
        _ = try await cloud.devices()
        XCTAssertEqual(authCalls, 2)
    }
    func testGoToRequiresFreshRealPositionAndBounds() throws {
        let now=Date(timeIntervalSince1970:1_700_000_000)
        var payload:[String:Any] = ["size":[0,0,0,0,100,100,50],"robot_position":[100,100,0],"timestamp_ms":1_700_000_000_000]
        XCTAssertEqual(try GoToController.validateTarget(x:1000,y:1000,map:JSONValue(any:payload),now:now),100)
        XCTAssertThrowsError(try GoToController.validateTarget(x:100,y:100,map:JSONValue(any:payload),now:now))
        XCTAssertThrowsError(try GoToController.validateTarget(x:6000,y:100,map:JSONValue(any:payload),now:now))
        payload["timestamp_ms"]=1_600_000_000_000
        XCTAssertThrowsError(try GoToController.validateTarget(x:1000,y:1000,map:JSONValue(any:payload),now:now))
        XCTAssertFalse(GoToController.supports(model:"dreame.vacuum.unknown"))
    }
    private func client() -> CloudClient {
        let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [CloudMockProtocol.self]
        return CloudClient(session:URLSession(configuration:config))
    }
    private let auth = #"{"access_token":"test-token","refresh_token":"test-refresh","expires_in":3600,"uid":"123","region":"EU","lang":"en","country":"DE"}"#
    func testLoginListAndSignedRPC() async throws {
        var calls = 0
        CloudMockProtocol.handler = { [auth] request in
            calls += 1
            if request.url!.path.contains("oauth") { return (200,Data(auth.utf8)) }
            XCTAssertEqual(request.value(forHTTPHeaderField:"dreame-auth"),"test-token")
            XCTAssertNotNil(request.value(forHTTPHeaderField:"dreame-rlc"))
            if request.url!.path.hasSuffix("listV2") { return (200,Data(#"{"code":0,"data":{"page":{"records":[{"did":"456","model":"dreame.vacuum.test","masterUid":"123","bindDomain":"test.example","customName":"Test"}]}}}"#.utf8)) }
            XCTAssertEqual(request.url!.path,"/dreame-iot-com-test/device/sendCommand")
            return (200,Data(#"{"code":0,"data":{"result":[{"code":0,"value":100}]}}"#.utf8))
        }
        let cloud = client(); _ = try await cloud.login(username:"test@example.invalid",password:"test",country:"sg")
        let devices = try await cloud.devices(); XCTAssertEqual(devices.first?.name,"Test")
        let result = try await cloud.rpc(device:devices[0],method:"get_properties",params:.array([]))
        XCTAssertEqual(result.array?.first?["value"].int,100); XCTAssertEqual(calls,3)
        await cloud.logout()
        do { _ = try await cloud.devices(); XCTFail("logged out") } catch CloudError.notAuthenticated {}
    }
    func testCanonicalSignatureUnicodeAndNestedArrays() throws {
        let value = try CloudClient.canonicalSignatureInput(["x":.object(["b":.string("Türkçe"),"a":.array([.integer(1)])]),"q":.array([.integer(2)]),"n":.null])
        XCTAssertEqual(value,"n=null&q=[2]&x=[b=\"Türkçe\"]")
    }
    func testNumericFoundationBridge() throws {
        let json = try JSONDecoder().decode(JSONValue.self,from:Data(#"{"siid":3,"piid":1,"code":0,"value":100}"#.utf8))
        let row = try XCTUnwrap(json.anyValue as? [String:Any])
        XCTAssertEqual(row["siid"] as? Int,3)
        XCTAssertEqual(DeviceContract.property([row],3,1) as? Int,100)
        try DeviceContract.requireAcknowledgement([row])
    }
    func testAuthenticationAndServerErrors() async throws {
        CloudMockProtocol.handler = { _ in (401,Data()) }
        do { _ = try await client().login(username:"test",password:"test",country:"sg"); XCTFail() } catch CloudError.authenticationRejected {}
        CloudMockProtocol.handler = { _ in (503,Data()) }
        do { _ = try await client().login(username:"test",password:"test",country:"sg"); XCTFail() } catch CloudError.server(503) {}
        do { _ = try await client().login(username:"test",password:"test",country:"../bad"); XCTFail() } catch CloudError.invalidRegion {}
    }
    func testMissingCommandResultNotRetried() async throws {
        var commands = 0
        CloudMockProtocol.handler = { [auth] request in
            if request.url!.path.contains("oauth") { return (200,Data(auth.utf8)) }
            commands += 1; return (200,Data(#"{"code":0,"success":true,"data":{}}"#.utf8))
        }
        let cloud = client(); _ = try await cloud.login(username:"test",password:"test",country:"sg")
        let device = try CloudDevice(raw:.object(["did":.string("1"),"model":.string("dreame.vacuum.test")]))
        do { _ = try await cloud.rpc(device:device,method:"action",params:.object([:])); XCTFail() } catch CloudError.commandResultUnknown {}
        XCTAssertEqual(commands,1)
    }
    func testServiceUsesReportedValuesAndRejectsFailedAction() async throws {
        CloudMockProtocol.handler = { [auth] request in
            let path = request.url!.path
            if path.contains("oauth") { return (200,Data(auth.utf8)) }
            if path.hasSuffix("listV2") { return (200,Data(#"{"code":0,"data":{"page":{"records":[{"did":"456","model":"dreame.vacuum.r2338a","masterUid":"123","customName":"Test","online":1}]}}}"#.utf8)) }
            // Status poll has request id 2. Tests never reach the network.
            let body:Data
            if let direct = request.httpBody { body = direct }
            else if let stream = request.httpBodyStream { stream.open(); defer { stream.close() }; var data=Data(); var buffer=[UInt8](repeating:0,count:4096); while stream.hasBytesAvailable { let n=stream.read(&buffer,maxLength:buffer.count); if n<=0 { break }; data.append(buffer,count:n) }; body=data }
            else { body=Data() }
            let payload = try JSONDecoder().decode(JSONValue.self,from:body)
            if payload["data"]["method"].string == "get_properties" { return (200,Data(#"{"code":0,"data":{"result":[{"siid":3,"piid":1,"code":0,"value":87},{"siid":4,"piid":4,"code":0,"value":2},{"siid":7,"piid":2,"code":0,"value":"EN"},{"siid":27,"piid":1,"code":-1,"value":99}]}}"#.utf8)) }
            return (200,Data(#"{"code":0,"data":{"result":{"code":-1}}}"#.utf8))
        }
        let service=DeviceService(cloud:client()); try await service.login(username:"test",password:"test",region:"sg",remember:false)
        let state=await service.publicState(); let device=try XCTUnwrap(state["device"] as? [String:Any])
        XCTAssertEqual(device["battery"] as? Int,87); XCTAssertEqual(device["suction"] as? Int,2)
        XCTAssertEqual(device["online"] as? Bool,true)
        XCTAssertEqual((device["supports"] as? [String:Bool])?["voice"],true,"String voice language must not hide the sound editor")
        let dock=try XCTUnwrap(device["dock_health"] as? [String:[String:Any]])
        XCTAssertTrue(dock["clean_water"]?["value"] is NSNull)
        do { try await service.action("start"); XCTFail("must reject nonzero code") } catch DeviceContract.ContractError.rejected {}
        do { try await service.setting("suction",value:4); XCTFail("Maks+ not reported") } catch DeviceService.ServiceError.unsupported {}
    }
    func testEmptyPropertyResponseFailsRatherThanReportingFreshState() async throws {
        CloudMockProtocol.handler = { [auth] request in
            let path=request.url!.path
            if path.contains("oauth") { return (200,Data(auth.utf8)) }
            if path.hasSuffix("listV2") { return (200,Data(#"{"code":0,"data":{"page":{"records":[{"did":"456","model":"dreame.vacuum.r2338a"}]}}}"#.utf8)) }
            return (200,Data(#"{"code":0,"data":{"result":[]}}"#.utf8))
        }
        let service=DeviceService(cloud:client())
        do { try await service.login(username:"test",password:"test",region:"sg",remember:false); XCTFail("empty status must fail") } catch CloudError.invalidResponse {}
        let state=await service.publicState(),device=try XCTUnwrap(state["device"] as? [String:Any])
        XCTAssertNil(device["updated_at"]); XCTAssertNil(device["battery"])
    }
}
