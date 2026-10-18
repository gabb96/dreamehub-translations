import XCTest
@testable import DreameCore

final class LoopbackHTTPServerTests:XCTestCase {
    private func request(_ extra:String="",path:String="/api/state",host:String="127.0.0.1:61326") throws -> LoopbackHTTPServer.Request {
        try XCTUnwrap(LoopbackHTTPServer.parse(Data("GET \(path) HTTP/1.1\r\nHost: \(host)\r\n\(extra)\r\n".utf8)))
    }
    func testPartialAndAmbiguousRequests() throws {
        XCTAssertNil(try LoopbackHTTPServer.parse(Data("GET / HTTP/1.1\r\nHost:".utf8)))
        XCTAssertThrowsError(try LoopbackHTTPServer.parse(Data("GET / HTTP/1.1\r\nHost: localhost\r\nHost: evil\r\n\r\n".utf8)))
        XCTAssertThrowsError(try LoopbackHTTPServer.parse(Data("POST /api/action HTTP/1.1\r\nHost: localhost\r\nTransfer-Encoding: chunked\r\n\r\n".utf8)))
        XCTAssertThrowsError(try LoopbackHTTPServer.parse(Data("POST /api/action HTTP/1.1\r\nHost: localhost\r\nContent-Length: 99999999\r\n\r\n".utf8)))
        XCTAssertThrowsError(try LoopbackHTTPServer.parse(Data(repeating:65,count:LoopbackHTTPServer.maxHeaders+1)))
    }
    func testHostAndRemoteIdentity() throws {
        XCTAssertFalse(try LoopbackHTTPServer.isRemote(request(),port:61326))
        XCTAssertThrowsError(try LoopbackHTTPServer.isRemote(request(host:"127.0.0.1:99"),port:61326))
        XCTAssertThrowsError(try LoopbackHTTPServer.isRemote(request(host:"evil.example"),port:61326))
        XCTAssertThrowsError(try LoopbackHTTPServer.isRemote(request(host:"mac.ts.net:8443"),port:61326))
        XCTAssertTrue(try LoopbackHTTPServer.isRemote(request("Tailscale-User-Login: user@example.invalid\r\n",host:"mac.ts.net:8443"),port:61326))
    }
    func testRemoteSensitiveEndpointsBlocked() {
        for path in ["/api/login","/api/logout","/api/credentials","/api/credentials/forget","/api/device/select","/api/tailscale/enable","/api/voice/editor/audio/1","/api/voice/install","/native/control"] { XCTAssertFalse(LoopbackHTTPServer.remoteAllowed(path:path),path) }
        XCTAssertTrue(LoopbackHTTPServer.remoteAllowed(path:"/api/map/current"))
    }
    func testLoopbackGETAndCSRFRejection() async throws {
        let server=LoopbackHTTPServer(resourceRoot:URL(fileURLWithPath:"/nonexistent")) { method,path,_,_ in ["status":200,"body":["method":method,"path":path]] }
        let port=try await server.start(); defer { server.stop() }
        let url=try XCTUnwrap(URL(string:"http://127.0.0.1:\(port)/api/state"))
        let (data,response)=try await URLSession.shared.data(from:url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode,200)
        let result=try JSONSerialization.jsonObject(with:data) as? [String:String]; XCTAssertEqual(result?["method"],"GET")
        var post=URLRequest(url:url); post.httpMethod="POST"; post.httpBody=Data("{}".utf8); post.setValue("application/json",forHTTPHeaderField:"Content-Type")
        let (_,denied)=try await URLSession.shared.data(for:post)
        XCTAssertEqual((denied as? HTTPURLResponse)?.statusCode,403)
    }
}
