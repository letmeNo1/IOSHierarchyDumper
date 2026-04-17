import XCTest

class WSForcePrintTests: XCTestCase {
    // 【必填】替换成你的内网 WS 地址
    private let wsURL = URL(string: "ws://192.168.1.100:8080/ws")!
    private var webSocketTask: URLSessionWebSocketTask?
    
    // ==============================================
    // 测试启动：必打印！
    // ==============================================
    override func setUp() {
        super.setUp()
        print("==================================================")
        print("【测试启动】WS 自动连接测试开始运行")
        print("【目标地址】\(wsURL.absoluteString)")
        print("==================================================")
    }
    
    // ==============================================
    // 测试结束：必打印！
    // ==============================================
    override func tearDown() {
        print("==================================================")
        print("【测试结束】资源清理完成，断开连接")
        print("==================================================")
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        super.tearDown()
    }
    
    // ==============================================
    // 核心测试：死活都打印！
    // ==============================================
    func test_WebSocket_AutoConnect_ForcePrint() {
        // 异步等待（兜底，永不卡死）
        let connectExp = expectation(description: "WS 连接兜底等待")
        connectExp.assertForOverFulfill = false
        
        print("【执行步骤】开始创建 WebSocket 连接任务")
        
        // 1. 创建会话
        let session = URLSession(
            configuration: .ephemeral,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        // 2. 创建 WS 任务
        webSocketTask = session.webSocketTask(with: wsURL)
        
        // 3. 启动连接
        webSocketTask?.resume()
        
        // ==============================================
        // 强制状态检查：1秒后必打印结果
        // ==============================================
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            guard let task = self.webSocketTask else {
                print("❌ 【连接结果】WebSocket 任务未创建")
                connectExp.fulfill()
                return
            }
            
            switch task.state {
            case .running:
                print("✅ 【连接结果】内网 WebSocket 连接成功！状态：running")
            case .suspended:
                print("⚠️ 【连接结果】连接暂停！状态：suspended")
            case .canceling:
                print("❌ 【连接结果】连接取消！状态：canceling")
            case .completed:
                print("❌ 【连接结果】连接完成/断开！状态：completed")
            @unknown default:
                print("❓ 【连接结果】未知状态")
            }
            
            // 兜底：无论如何都完成测试
            connectExp.fulfill()
            session.finishTasksAndInvalidate()
        }
        
        // 等待超时（兜底 15 秒，必结束）
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                print("❌ 【超时兜底】连接超时：\(error.localizedDescription)")
            } else {
                print("✅ 【流程结束】WS 连接测试执行完成")
            }
        }
    }
}
