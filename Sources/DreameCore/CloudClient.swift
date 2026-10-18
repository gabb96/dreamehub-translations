// Dreame protocol interoperability port; see THIRD_PARTY_NOTICES for upstream attribution.
import Foundation
import CryptoKit
import CommonCrypto

/// HTTP cloud transport. Does not synthesize telemetry and never retries a device command.
public actor CloudClient {
    private let session: URLSession
    private var country = "sg"
    private var username = ""
    private var accessToken: String?
    private var refreshToken: String?
    private var expiresAt = Date.distantPast
    private var userID = ""
    private var tenantID = "000000"
    private var region: String?
    private var language: String?
    private var countryCode: String?
    private var requestID = Int.random(in: 1...100)
    private var authGeneration = 0
    private let visitorID = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    // Public application interoperability constants, not user credentials.
    private let clientID = "EETjszu*XI5znHsI"
    public init(session: URLSession = .shared) { self.session = session }

    @discardableResult public func login(username: String, password: String, country: String) async throws -> CloudSession {
        guard ["cn", "sg", "us", "eu", "ru", "kr"].contains(country) else { throw CloudError.invalidRegion }
        authGeneration += 1
        self.country = country; self.username = username
        self.accessToken = nil; self.refreshToken = nil
        self.tenantID = "000000"; self.region = nil; self.language = nil; self.countryCode = nil
        let fields = "grant_type=password&scope=all&platform=ANDROID&type=account&username=\(Self.escaped(username))&password=\(Self.md5(password + "RAylYC%fmSKp7%Tq"))"
        return try await authenticate(body: fields)
    }

    public func logout() { authGeneration += 1; accessToken = nil; refreshToken = nil; username = ""; userID = ""; expiresAt = .distantPast }

    private var baseURL: String { "https://\(country).iot.dreame.tech:13267" }
    private static func md5(_ text: String) -> String { Insecure.MD5.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined() }
    private static func escaped(_ text: String) -> String { text.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")) ?? "" }

    private func headers(contentType: String, authenticated: Bool) throws -> [String:String] {
        var result = ["User-Agent":"Dart/3.9 (dart:io)", "authorization":"Basic ZHJlYW1lX2FwcHYxOkFQXmR2QHpAU1FZVnhOODg=", "tenant-id":tenantID, "content-type":contentType,
                      "dreame-meta":"cv=a_102060300;canvasHash=\(Self.md5(username + "c").prefix(8));webglHash=\(Self.md5(username + "w").prefix(8));visitorIdHash=\(visitorID)"]
        if authenticated, let token = accessToken { result["dreame-auth"] = token }
        if let region, let language, let countryCode {
            let data = Data("\(region)|\(language)|\(countryCode)".utf8), key = Data(clientID.utf8)
            var output = Data(count: data.count + kCCBlockSizeAES128), length = 0
            let capacity = output.count
            let status = output.withUnsafeMutableBytes { out in data.withUnsafeBytes { bytes in key.withUnsafeBytes { k in
                CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionECBMode | kCCOptionPKCS7Padding), k.baseAddress, key.count, nil, bytes.baseAddress, data.count, out.baseAddress, capacity, &length)
            } } }
            guard status == kCCSuccess else { throw CloudError.cryptoFailure }
            output.count = length; result["dreame-rlc"] = output.base64EncodedString()
        }
        return result
    }

    private func authenticate(body: String) async throws -> CloudSession {
        let epoch = authGeneration
        let data = try await transport(path: "/dreame-auth/oauth/token", body: Data(body.utf8), contentType: "application/x-www-form-urlencoded", authenticated: false)
        guard epoch == authGeneration else { throw CloudError.notAuthenticated }
        let response = try JSONDecoder().decode(JSONValue.self, from: data)
        guard let token = response["access_token"].string, !token.isEmpty else { throw CloudError.authenticationRejected }
        accessToken = token; refreshToken = response["refresh_token"].string
        expiresAt = Date().addingTimeInterval(Double(response["expires_in"].int ?? 3600))
        userID = response["uid"].string ?? userID
        tenantID = response["tenant_id"].string ?? tenantID
        region = response["region"].string ?? region; language = response["lang"].string ?? language; countryCode = response["country"].string ?? countryCode
        return CloudSession(userID: userID, country: country, expiresAt: expiresAt)
    }

    private func ensureSession() async throws {
        guard accessToken != nil else { throw CloudError.notAuthenticated }
        if expiresAt.timeIntervalSinceNow < 600 {
            guard let refreshToken else { throw CloudError.notAuthenticated }
            _ = try await authenticate(body: "grant_type=refresh_token&scope=all&platform=ANDROID&type=account&refresh_token=\(Self.escaped(refreshToken))")
        }
    }

    private func transport(path: String, body: Data?, contentType: String = "application/json", authenticated: Bool = true) async throws -> Data {
        let epoch = authGeneration
        guard let url = URL(string: baseURL + path) else { throw CloudError.invalidURL }
        var request = URLRequest(url: url); request.httpMethod = "POST"; request.httpBody = body; request.timeoutInterval = 20
        request.allHTTPHeaderFields = try headers(contentType: contentType, authenticated: authenticated)
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw CloudError.invalidResponse }
        guard (200..<300).contains(response.statusCode) else {
            if [400,401,403].contains(response.statusCode), !authenticated { throw CloudError.authenticationRejected }
            if response.statusCode == 401 { if epoch == authGeneration { accessToken = nil }; throw CloudError.notAuthenticated }
            throw CloudError.server(response.statusCode)
        }
        return data
    }

    /// The server signs sorted fields, with arrays only at the top level.
    public static func canonicalSignatureInput(_ values: [String:JSONValue], topLevel: Bool = true) throws -> String {
        try values.keys.sorted().compactMap { key -> String? in
            let v = values[key]!
            switch v {
            case .object(let nested):
                let inner = try canonicalSignatureInput(nested, topLevel: false)
                return inner.isEmpty ? "\(key)=]" : "\(key)=[\(inner)]"
            case .array:
                return topLevel ? "\(key)=\(String(decoding: try v.data(), as: UTF8.self))" : nil
            case .string(let s): return "\(key)=\(topLevel ? s : String(decoding: try v.data(), as: UTF8.self))"
            default: return "\(key)=\(String(decoding: try v.data(), as: UTF8.self))"
            }
        }.joined(separator: "&")
    }

    private func api(_ path: String, params: [String:JSONValue]? = nil) async throws -> JSONValue {
        try await ensureSession()
        var body: Data?
        if var params {
            let timestamp = Int(Date().timeIntervalSince1970 * 1000)
            params["sign"] = .string(Self.md5(try Self.canonicalSignatureInput(params) + String(timestamp) + clientID))
            params["timestamp"] = .integer(timestamp)
            body = try JSONValue.object(params).data()
        }
        let data = try await transport(path: "/" + path, body: body)
        let result = try JSONDecoder().decode(JSONValue.self, from: data)
        if let code = result["code"].int, code != 0 { throw CloudError.api(code) }
        return result
    }

    public func devices() async throws -> [CloudDevice] {
        let response = try await api("dreame-user-iot/iotuserbind/device/listV2")
        guard let records = response["data"]["page"]["records"].array else { throw CloudError.invalidResponse }
        return try records.filter { $0["model"].string?.contains(".vacuum.") == true }.map(CloudDevice.init)
    }

    public func deviceInfo(device: CloudDevice) async throws -> JSONValue {
        try await api("dreame-user-iot/iotuserbind/device/info", params: ["did":.string(device.id)])["data"]
    }

    public func rpc(device: CloudDevice, method: String, params: JSONValue) async throws -> JSONValue {
        requestID += 1
        let host = device.bindDomain.split(separator: ".").first.map(String.init) ?? ""
        guard host.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }) else { throw CloudError.invalidURL }
        let suffix = host.isEmpty ? "" : "-" + host
        let response = try await api("dreame-iot-com\(suffix)/device/sendCommand", params: ["did":.string(device.id), "id":.integer(requestID), "data":.object(["did":.string(device.id), "id":.integer(requestID), "method":.string(method), "params":params])])
        guard let result = response["data"].object?["result"] else { throw CloudError.commandResultUnknown }
        return result
    }

    public func properties(device: CloudDevice, keys: [String]) async throws -> JSONValue {
        try await api("dreame-user-iot/iotstatus/props", params: ["did":.string(device.id), "keys":.string(keys.joined(separator:","))])["data"]
    }

    public func history(device: CloudDevice, siid: Int, piid: Int, limit: Int = 1, from: Int = 1687019188) async throws -> JSONValue {
        try await api("dreame-user-iot/iotstatus/history", params: ["uid":.string(device.ownerID), "did":.string(device.id), "from":.integer(from), "limit":.integer(limit), "siid":.string(String(siid)), "piid":.string(String(piid)), "region":.string(country), "type":.integer(3)])["data"]["list"]
    }

    public func fileURL(device: CloudDevice, objectName: String, interim: Bool = false) async throws -> JSONValue {
        var params: [String:JSONValue] = ["did":.string(device.id), "model":.string(device.model), "filename":.string(interim ? objectName : String(objectName.dropFirst())), "region":.string(country)]
        if !interim { params["uid"] = .string(device.ownerID) }
        return try await api("dreame-user-iot/iotfile/" + (interim ? "getDownloadUrl" : "getOss1dDownloadUrl"), params: params)["data"]
    }

    public func events(device: CloudDevice, siid: Int, eiid: Int, limit: Int = 20, from: Int = 1687019188) async throws -> JSONValue {
        try await api("dreame-user-iot/iotstatus/history", params: ["uid":.string(device.ownerID), "did":.string(device.id), "from":.integer(from), "limit":.integer(limit), "siid":.string(String(siid)), "eiid":.string(String(eiid)), "region":.string(country), "type":.integer(3)])["data"]["list"]
    }

    public func download(url: URL) async throws -> Data {
        guard url.scheme == "https", url.host != nil, url.user == nil, url.password == nil else { throw CloudError.invalidURL }
        var request = URLRequest(url: url); request.timeoutInterval = 20; request.setValue("okhttp/4.12.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw CloudError.invalidResponse }
        return data
    }

    public func deviceFile(device: CloudDevice, filename: String, type: String) async throws -> Data {
        try await ensureSession()
        let info = String(decoding: try JSONValue.object(["filename":.string(filename), "type":.string(type)]).data(), as: UTF8.self)
        var params: [String:JSONValue] = ["did":.string(device.id), "uid":.string(device.ownerID), "fileinfo":.string(info)]
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        params["sign"] = .string(Self.md5(try Self.canonicalSignatureInput(params) + String(timestamp) + clientID)); params["timestamp"] = .integer(timestamp)
        return try await transport(path: "/file-bridge/user/getDeiviceFile", body: JSONValue.object(params).data())
    }
}
