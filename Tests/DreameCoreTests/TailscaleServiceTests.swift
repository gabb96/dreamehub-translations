import XCTest
@testable import DreameCore

final class TailscaleServiceTests:XCTestCase {
    func testPortValidation() {
        XCTAssertFalse(TailscaleService.validPort(0)); XCTAssertFalse(TailscaleService.validPort(80)); XCTAssertFalse(TailscaleService.validPort(65536)); XCTAssertTrue(TailscaleService.validPort(61326))
    }
    func testExactProxyDoesNotConfuseOtherServices() throws {
        let value=try JSONValue(any:["Web":["example.ts.net:8443":["Handlers":["/":["Proxy":"http://127.0.0.1:61326"]]]],"AllowFunnel":["example.ts.net:8443":false]])
        XCTAssertEqual(TailscaleService.proxy(value,dnsName:"example.ts.net"),"http://127.0.0.1:61326")
        XCTAssertNil(TailscaleService.proxy(value,dnsName:"other.ts.net"))
        XCTAssertFalse(TailscaleService.hasPublicFunnel(value,dnsName:"example.ts.net"))
    }
    func testFunnelDetection() throws {
        let value=try JSONValue(any:["AllowFunnel":["example.ts.net:8443":true]])
        XCTAssertTrue(TailscaleService.hasPublicFunnel(value,dnsName:"example.ts.net"))
    }
    func testReadOnlyMockStatusDoesNotCallServeMutation() async throws {
        let service=TailscaleService(executable:"/not-executed/tailscale",preferences:URL(fileURLWithPath:"/nonexistent/preferences.json"),runner:{ _,args in
            if args == ["status","--json"] { return .init(status:0,output:Data(#"{"BackendState":"Running","Self":{"DNSName":"example.ts.net."}}"#.utf8)) }
            XCTAssertEqual(args,["serve","status","--json"])
            return .init(status:0,output:Data(#"{"Web":{"example.ts.net:8443":{"Handlers":{"/":{"Proxy":"http://127.0.0.1:61326"}}}}}"#.utf8))
        })
        let status=try await service.status(localPort:61326)
        XCTAssertEqual(status["enabled"] as? Bool,true)
        XCTAssertEqual(status["url"] as? String,"https://example.ts.net:8443/")
    }
}
