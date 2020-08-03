import Foundation
import Swifter

class LocalWebServer {
    private var server: HttpServer?
    
    func run() {
        let server = HttpServer()
        
        server.get["/list"] = { r in
            let videoTitles = store.state.videos.videos.map(\.title)
            let jsonMap = ["titles" : videoTitles]
            
            return .ok(.json(jsonMap))
        }
        
        server["/js/:path"] = shareFilesFromDirectory(Bundle.main.bundlePath)
        server["/fonts/:path"] = shareFilesFromDirectory(Bundle.main.bundlePath)
        server["/css/:path"] = shareFilesFromDirectory(Bundle.main.bundlePath)
                        
        if let indexHtmlUrl = Bundle.main.url(forResource: "index", withExtension: "html"),
            let indexHtml = try? String(contentsOf: indexHtmlUrl) {
            server.get["/"] = { r in
                .ok(.html(indexHtml))
            }
        }

        server.post["/upload"] = { r in
            let multiPartFormData = r.parseMultiPartFormData()
            
            if let videoPart = multiPartFormData.filter({ $0.name == "video" }).first,
                let sourceSubtitlePart = multiPartFormData.filter({ $0.name == "sourceSubtitle" }).first {
                let videoData: NSData = videoPart.body.withUnsafeBufferPointer { pointer in
                    return NSData(bytes: pointer.baseAddress, length: videoPart.body.count)
                }
                let sourceSubtitleData: NSData = sourceSubtitlePart.body.withUnsafeBufferPointer { pointer in
                    return NSData(bytes: pointer.baseAddress, length: sourceSubtitlePart.body.count)
                }
                print(videoData)
                print(sourceSubtitleData)
                
                let action = AppStateActions.SaveVideo(
                    videoData: videoData as Data,
                    sourceSubtitleData: sourceSubtitleData as Data
                )
                store.dispatch(action: action)
                
                return .ok(.html("Your file has been uploaded !"))
            }
            
            print("internalServerError")
            return .internalServerError
        }

        do {
            try server.start(9099, forceIPv4: true)
            print(getWiFiAddress() ?? "No ip")
        } catch {
            print("Server start error: \(error)")
        }
        self.server = server
    }
    
    func getWiFiAddress() -> String? {
        var address : String?

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
}
