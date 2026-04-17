import XCTest
import Network
import UIKit

class WSForcePrintTests: XCTestCase {
    
    // 🔥 修正1：去掉 .json！和Flask接口完全匹配
    private let remoteConfigURL = URL(string: "http://10.86.213.3:8000/config")!
    private var wsURL: URL!
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var browser: NWBrowser?
    
    // 获取设备UUID
    private func getDeviceUUID() -> String {
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
            XCTFail("❌ 无法获取设备UUID")
            return ""
        }
        print("📱 当前设备UUID：\(uuid)")
        return uuid
    }
    
    // 🔥 修正2：解析服务端的 {"devices": [...]} 结构
    private func fetchAndMatchWSURL() async throws {
        let currentUUID = getDeviceUUID()
        if currentUUID.isEmpty { throw NSError(domain: "UUID错误", code: -1) }
        
        // 请求配置
        let (data, response) = try await URLSession.shared.data(from: remoteConfigURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "网络请求失败", code: -2)
        }
        
        // 匹配Flask服务的JSON结构！！！
        struct DeviceConfig: Codable {
            let deviceUUID: String  // 必须和config.json一致
            let wsUrl: String       // 必须和config.json一致
        }
        // 外层包裹devices数组
        struct ConfigResponse: Codable {
            let devices: [DeviceConfig]
        }
        
        // 解析
        let config = try JSONDecoder().decode(ConfigResponse.self, from: data)
        guard let matchedConfig = config.devices.first(where: { $0.deviceUUID == currentUUID }) else {
            XCTFail("❌ 配置中未找到当前设备")
            throw NSError(domain: "无匹配配置", code: -3)
        }
        
        wsURL = URL(string: matchedConfig.wsUrl)!
        print("✅ 匹配成功！WebSocket：\(wsURL.absoluteString)")
    }
    
    // 本地网络权限
    func triggerLocalNetworkPermission() {
        let params = NWParameters()
        let browser = NWBrowser(for: .bonjour(type: "_http._tcp", domain: nil), using: params)
        self.browser = browser
        browser.stateUpdateHandler = { state in
            print("📡 Bonjour state: \(state)")
        }
        browser.start(queue: .main)
    }

    override func setUp() {
        super.setUp()
        print("==================================================")
        print("🚀 拉取远程配置...")
        
        let configExp = expectation(description: "拉取配置")
        Task {
            do {
                try await fetchAndMatchWSURL()
            } catch {
                XCTFail("❌ 配置失败：\(error.localizedDescription)")
            }
            configExp.fulfill()
        }
        wait(for: [configExp], timeout: 10)
        
        // 倒计时
        print("⏱ 10秒后启动测试...")
        for i in (1...10).reversed() {
            print("倒计时：\(i)")
            Thread.sleep(forTimeInterval: 1)
        }

        triggerLocalNetworkPermission()
    }

    override func tearDown() {
        webSocketTask?.cancel()
        browser?.cancel()
        super.tearDown()
    }

    // WebSocket测试
    func test_WebSocket_AutoConnect_ForcePrint() {
        let exp = expectation(description: "ws测试")
        print("📌 连接WebSocket：\(wsURL.absoluteString)")
        
        let session = URLSession(configuration: .ephemeral)
        webSocketTask = session.webSocketTask(with: wsURL)
        webSocketTask?.resume()
        
        // 3秒后发送ping测试
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.webSocketTask?.send(.string("ping")) { error in
                if let error = error {
                    print("❌ 发送失败：\(error.localizedDescription)")
                } else {
                    print("✅ WebSocket连接成功！")
                }
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15)
    }
}
