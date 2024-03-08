
import XCTest
import CocoaAsyncSocket

class MyServerTests: XCTestCase,GCDAsyncSocketDelegate {
    var listenThread: Thread!
    var listenSocket: GCDAsyncSocket!
    var connectedSockets = [GCDAsyncSocket]()
    var testExpectation: XCTestExpectation?
    var expectations: [XCTestExpectation] = []

    override func setUp() {
        super.setUp()

        // 创建一个新的线程来运行服务器
        listenThread = Thread(target: self, selector: #selector(startServer), object: nil)
        listenThread.start()
        print("Listening on port ")

        // 等待一段时间，确保服务器已经启动
        Thread.sleep(forTimeInterval: 1.0)
    }

    override func tearDown() {
        for expectation in expectations {
            expectation.fulfill()
        }
        super.tearDown()

        // 停止服务器
        listenSocket.disconnect()
        listenSocket = nil
        listenThread.cancel()
    }
    
    func testClienth() {

        for i in 0..<100 {
            let expectation = XCTestExpectation(description: "Receive response from server \(i)")
            expectations.append(expectation)
            // 在这里发送你的请求，并在接收到响应后满足期望
        }

        wait(for: expectations, timeout: 99990.0)
    }

    func startServer() {
        var customValueInt:UInt16 = 9090
        listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            if let customValueString = ProcessInfo.processInfo.environment["USE_PORT"] {
                        customValueInt = UInt16(customValueString) ?? 9090
                        print("The value of USE_PORT is: \(customValueString)")
                   } else {
                       // 环境变量未设置
                        print("USE_PORT is not set.")
                   }
            try listenSocket.accept(onPort: customValueInt)
            print("Listening on port \(listenSocket.localPort)")
            RunLoop.current.run()
        } catch {
            print("Failed to listen on port: \(error)")
        }
    }

    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("Accepted new socket from \(newSocket.connectedHost ?? ""):\(newSocket.connectedPort)")
        connectedSockets.append(newSocket)
        newSocket.readData(withTimeout: -1, tag: 0)
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if let message = String(data: data, encoding: .utf8) {
                  print("Received message: \(message)")
                  if message.contains("Close") {
                      tearDown()
                  }
                  if message.contains("print") {
                      let response = "HTTP/1.1 200 OK\r\n\r\n"
                      if let responseData = response.data(using: .utf8) {
                          sock.write(responseData, withTimeout: -1, tag: 0)
                      }
                  }
                 if message.contains("dump_tree") {
                     let bundle_id = message.split(separator: ":")[1]
                     let app = XCUIApplication(bundleIdentifier: bundle_id)
//                     app.launch()
                     print(app.debugDescription)
                     let response = app.debugDescription
                     if let responseData = response.data(using: .utf8) {
                        sock.write(responseData, withTimeout: -1, tag: 0)
                    }
                }
              }
              sock.disconnectAfterWriting()
    }
    
}
