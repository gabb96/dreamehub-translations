import Foundation

/// Read-only cleaning records and their archived map blobs. No routines or schedule mutation.
public actor HistoryService {
    private let cloud: CloudClient
    private var deviceID: String?
    private var records: [[String:JSONValue]] = []
    private var selectedCapture: MapService.Capture?
    public init(cloud:CloudClient) { self.cloud=cloud }
    public func list(device:CloudDevice) async throws -> JSONValue {
        let response=try await cloud.events(device:device,siid:4,eiid:1,limit:50)
        var result:[[String:JSONValue]]=[]
        var seen=Set<Int>()
        for record in response.array ?? [] {
            let blob=record["history"].string ?? record["value"].string
            guard let blob,let data=blob.data(using:.utf8),let properties=try? JSONDecoder().decode([JSONValue].self,from:data) else { continue }
            var values:[Int:JSONValue]=[:]
            for property in properties { if let id=property["piid"].int { values[id]=property.object?["value"] ?? property["val"] } }
            guard let timestamp=values[8]?.int,!seen.contains(timestamp) else { continue }
            seen.insert(timestamp)
            let formatter=DateFormatter();formatter.dateFormat="MM-dd HH:mm"
            var entry:[String:JSONValue]=["index":.integer(result.count+1),"date":.string(formatter.string(from:Date(timeIntervalSince1970:TimeInterval(timestamp)))),"timestamp":.integer(timestamp)]
            if let time=values[2]?.int { entry["cleaning_time"] = .string("\(time) min") }
            if let area=values[3]?.int { entry["cleaned_area"] = .string("\(area) m²") }
            if let completed=values[13]?.int { entry["completed"] = .bool(completed == 1) }
            if let file=values[9]?.string,!file.isEmpty { entry["_object_name"] = .string(file) }
            result.append(entry)
            if result.count == 30 { break }
        }
        records=result;deviceID=device.id
        // Object names and decryption keys never leave the service's private state.
        return .array(result.map { .object($0.filter { !$0.key.hasPrefix("_") }) })
    }
    public func map(device:CloudDevice,index:Int) async throws -> JSONValue {
        if deviceID != device.id || records.isEmpty { _=try await list(device:device) }
        guard index > 0,index <= records.count,let object=records[index-1]["_object_name"]?.string,
              let config=MapService.configuration(model:device.model) else { throw MapService.Failure.noMap }
        let parts=object.split(separator:",",maxSplits:1,omittingEmptySubsequences:false)
        let signed=try await cloud.fileURL(device:device,objectName:String(parts[0]),interim:true)
        guard let urlString=signed.string ?? signed["url"].string,let url=URL(string:urlString) else { throw MapService.Failure.signedURL }
        let data=try await cloud.download(url:url)
        guard let raw=String(data:data,encoding:.utf8) else { throw MapService.Failure.invalidText }
        let capture=MapService.Capture(raw:raw,iv:config.iv,key:parts.count>1 ? String(parts[1]):nil,version:config.version,source:"cleaning_history")
        var result=try MapDecoder.decode(raw,version:config.version,iv:config.iv,key:capture.key)
        result["history_map"]=true;result["history_index"]=index;result["acquisition_source"]="cleaning_history"
        selectedCapture=capture
        return try JSONValue(any:result)
    }
    public func photo(device:CloudDevice,obstacleID:String) async throws -> Data {
        guard deviceID == device.id,let selectedCapture else { throw MapService.Failure.noMap }
        return try await ObstaclePhotoService(cloud:cloud).image(device:device,capture:selectedCapture,index:obstacleID)
    }
}
