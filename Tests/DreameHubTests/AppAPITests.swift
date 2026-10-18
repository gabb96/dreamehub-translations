import XCTest
@testable import DreameHub

final class AppAPITests:XCTestCase {
    func testReadOnlyBuildBlocksEveryPhysicalMutationBeforeLogin() async {
        let api = AppAPI(readOnly:true)
        for path in ["/api/action","/api/setting","/api/go-to","/api/voice/install","/api/voice/editor/install","/api/tailscale/enable","/api/tailscale/disable","/api/credentials/forget"] {
            let result = await api.response(path:path,method:"POST",body:[:],binary:nil)
            XCTAssertEqual(result["status"] as? Int,400,path)
            let message = (result["body"] as? [String:Any])?["error"] as? String
            XCTAssertTrue(message?.contains("Yalnız okuma") == true,path)
        }
    }
    func testUnknownEndpointsDoNotSucceed() async {
        let api = AppAPI()
        let result = await api.response(path:"/api/unknown",method:"POST",body:[:],binary:nil)
        XCTAssertEqual(result["status"] as? Int,400)
    }
    func testInitialStateIsExplicitLoadingNotFakeDevice() async {
        let api = AppAPI()
        let result = await api.response(path:"/api/state",method:"GET",body:[:],binary:nil)
        let state = result["body"] as? [String:Any]
        XCTAssertEqual(state?["authenticated"] as? Bool,false)
        XCTAssertNil(state?["device"])
        XCTAssertEqual((state?["boot"] as? [String:Any])?["busy"] as? Bool,true)
    }
    func testReadOnlyStateIsExplicit() async {
        let api = AppAPI(readOnly:true)
        let result = await api.response(path:"/api/state",method:"GET",body:[:],binary:nil)
        XCTAssertEqual((result["body"] as? [String:Any])?["read_only"] as? Bool,true)
    }
    func testResourcesPackagedWithoutPython() throws {
        let root = ResourcePaths.root
        XCTAssertTrue(FileManager.default.fileExists(atPath:root.appendingPathComponent("index.html").path))
        let labels = try JSONSerialization.jsonObject(with:Data(contentsOf:root.appendingPathComponent("voice_labels_tr.json"))) as? [String:[String:String]]
        XCTAssertEqual(labels?["0"]?["name"],"Başlangıç melodisi")
        let enumerator = FileManager.default.enumerator(at:root,includingPropertiesForKeys:nil)!
        for case let url as URL in enumerator { XCTAssertFalse(["py","pyc"].contains(url.pathExtension)) }
    }
}
