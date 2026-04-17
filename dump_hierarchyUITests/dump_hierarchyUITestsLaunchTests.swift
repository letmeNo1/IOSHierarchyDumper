import XCTest
import Network

class WSForcePrintTests: XCTestCase {
    
    private let wsURL = URL(string: "ws://10.86.213.126:2080")!
    private var webSocketTask: URLSessionWebSocketTask?
    private var browser: NWBrowser?   // 🔥 用来触发权限
    
    // ==============================================
    // 🔥 强制触发 Local Network 权限
    // ==============================================
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
        print("【准备】测试将在 10 秒后启动...")
        
        for i in (1...10).reversed() {
            print("⏱ 倒计时：\(i)")
            Thread.sleep(forTimeInterval: 1)
        }

        print("==================================================")
        print("🚀 开始触发 Local Network 权限")
        
        triggerLocalNetworkPermission()   // 🔥 关键新增
        
        print("==================================================")
    }

    override func tearDown() {
        print("==================================================")
        print("【测试结束】资源清理")
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        browser?.cancel()
        browser = nil
        
        print("==================================================")
        super.tearDown()
    }

    func test_WebSocket_AutoConnect_ForcePrint() {

        let exp = expectation(description: "ws test")
        exp.assertForOverFulfill = false

        print("📌 创建 WebSocket...")

        let session = URLSession(configuration: .ephemeral)

        webSocketTask = session.webSocketTask(with: wsURL)
        webSocketTask?.resume()

        // ==============================================
        // 🔥 关键：发送 ping 判断是否真的连上
        // ==============================================
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {

            self.webSocketTask?.send(.string("ping")) { error in

                if let error = error {
                    print("❌ 【WS失败】无法发送数据：\(error.localizedDescription)")
                } else {
                    print("✅ 【WS成功】连接可用（send 成功）")
                }

                exp.fulfill()
            }
        }

        waitForExpectations(timeout: 15)

        print("🏁 测试结束")
    }
}
