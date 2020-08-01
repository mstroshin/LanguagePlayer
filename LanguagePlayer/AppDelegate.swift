import UIKit
import GCDWebServer
import Swifter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var webUploader: GCDWebUploader?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        if let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
//            let webUploader = GCDWebUploader(uploadDirectory: docPath)
//            webUploader.start()
////            print("Visit \(String(describing: webUploader.serverURL))")
//
//            self.webUploader = webUploader
//        }
        
        self.runSwifter()
        
        return true
    }
    
    private var server: HttpServer?
    func runSwifter() {
        let server = HttpServer()
        
        let uploadBody = """
        <form method=\"POST\" action=\"/upload\" enctype=\"multipart/form-data\">
        <input name=\"my_file\" type=\"file\"/>
        <button type=\"submit\">Send File</button>
        </form>
        """

        server.get["/"] = { r in
            .ok(.htmlBody(uploadBody))
        }
        
        server.post["/upload"] = { r in
            if let myFileMultipart = r.parseMultiPartFormData().filter({ $0.name == "my_file" }).first {
                guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    return .internalServerError
                }
                let data: NSData = myFileMultipart.body.withUnsafeBufferPointer { pointer in
                    return NSData(bytes: pointer.baseAddress, length: myFileMultipart.body.count)
                }
                guard let fileSaveUrl = NSURL(string: "name_for_file.txt", relativeTo: documentsUrl) else {
                    return .internalServerError
                }
                print(fileSaveUrl)
                data.write(to: fileSaveUrl as URL, atomically: true)
                return .ok(.html("Your file has been uploaded !"))
            }
            return .internalServerError
        }

        do {
            try server.start(9099)
            print(getWiFiAddress())
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

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

