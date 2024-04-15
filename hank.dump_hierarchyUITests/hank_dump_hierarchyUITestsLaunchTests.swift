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
        continueAfterFailure = false
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
        var customValueInt:UInt16 = 8200
        listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            if let customValueString = ProcessInfo.processInfo.environment["USE_PORT"] {
                        customValueInt = UInt16(customValueString) ?? 8200
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
                     let bundle_id = String(message.split(separator: ":")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                     print(bundle_id + "is the bundle id")
                     let app = XCUIApplication(bundleIdentifier: String(bundle_id))
//                     app.launch()
                     print(app.debugDescription)
                     let response = app.debugDescription
                     if let responseData = response.data(using: .utf8) {
                        sock.write(responseData, withTimeout: -1, tag: 0)
                    }
                }
            if message.contains("get_pic"){
                let screenshot = XCUIScreen.main.screenshot()
                let imageData = screenshot.pngRepresentation
        
                sock.write(imageData, withTimeout: -1, tag: 0)
            }
            if message.contains("found_element") {
                let bundle_id = String(message.split(separator: ":")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                let condition = String(message.split(separator: ":")[2]).trimmingCharacters(in: .whitespacesAndNewlines)
 
                print(bundle_id + "is the bundle id")
                let app = XCUIApplication(bundleIdentifier: String(bundle_id))
                var element:XCUIElement
                if condition.contains("index"){
                    let index = String(message.split(separator: ":")[3]).trimmingCharacters(in: .whitespacesAndNewlines)
                    element = app.descendants(matching: .any).element(boundBy: Int(index)!)
                }else{
            
                    let predicate = NSPredicate(format: condition)
                    element = app.descendants(matching: .any ).element(matching: predicate)
                }
        
                do {
                    let response = try element.snapshot().dictionaryRepresentation
                    let responseData = try JSONSerialization.data(withJSONObject: response, options: [])
                    sock.write(responseData, withTimeout: -1, tag: 0)
                   
                    
                    // 使用 element
                } catch {
                    let response = ""
                    if let responseData = response.data(using: .utf8) {
                        sock.write(responseData, withTimeout: -1, tag: 0)
                    }
                }
                
            }
            if message.contains("get_current_bundleIdentifier") {
                            let ios_system_bundle_identifiers = [
                                "com.apple.Preferences",
                                "com.apple.mobilephone",
                                "com.apple.MobileSMS",
                                "com.apple.camera",
                                "com.apple.mobileslideshow",
                                "com.apple.mobilemail",
                                "com.apple.mobilesafari",
                                "com.apple.mobilecal",
                                "com.apple.reminders",
                                "com.apple.mobilenotes",
                                "com.apple.Music",
                                "com.apple.Maps",
                                "com.apple.springboard"
                            ]
                            let messageParts = message.split(separator: ":").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                               var response = "No frontmost app found"
                               if messageParts.count > 1 {
                                   let bundle_ids = Array(messageParts[1...]) + ios_system_bundle_identifiers
                                   for bundleId in bundle_ids {
                                       let app = XCUIApplication(bundleIdentifier: bundleId)
                                       if app.state == .runningForeground {
                                           response = bundleId
                                           break
                                       }
                                   }
                               }
                               if let responseData = response.data(using: .utf8) {
                                   sock.write(responseData, withTimeout: -1, tag: 0)
                               }
            }
            if message.contains("get_pic"){
                let screenshot = XCUIScreen.main.screenshot()
                let imageData = screenshot.pngRepresentation
                print(imageData)
                        // 直接发送屏幕截图数据
                sock.write(imageData, withTimeout: -1, tag: 0)
            }
            if message.contains("action") {
                UIView.setAnimationsEnabled(false)
                DispatchQueue.main.async {
                    let message_debug = message.trimmingCharacters(in: .whitespacesAndNewlines)
                    let bundle_id = message_debug.split(separator: ":")[1]
                    print(bundle_id + "is the bundle id")
                    let app = XCUIApplication(bundleIdentifier: String(bundle_id))
                    let action = message_debug.split(separator: ":")[2]
                    let xPixel = CGFloat(Float(message_debug.split(separator: ":")[3]) ?? 0.0)
                    let yPixel = CGFloat(Float(message_debug.split(separator: ":")[4]) ?? 0.0)
                    let windowFrame = app.windows.element(boundBy: 0).frame
                    let windowWidth = windowFrame.width
                    let windowHeight = windowFrame.height
                    let xNormalized = xPixel / windowWidth
                    let yNormalized = yPixel / windowHeight

                    let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: xNormalized, dy: yNormalized))
                    
                    switch action {
                    case "tap":
                        coordinate.tap()
                    case "longPress":
                        let duration = Double(message_debug.split(separator: ":")[5]) ?? 1.0
                        coordinate.press(forDuration: duration)
                    case "drag":
                        let x2Pixel = CGFloat(Float(message_debug.split(separator: ":")[5]) ?? 0.0)
                        let y2Pixel = CGFloat(Float(message_debug.split(separator: ":")[6]) ?? 0.0)
                        let x2Normalized = x2Pixel / windowWidth
                        let y2Normalized = y2Pixel / windowHeight
                        let destinationCoordinate = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: x2Normalized, dy: y2Normalized))
                        let dragDuration = Double(message_debug.split(separator: ":")[7]) ?? 1.0
                        coordinate.press(forDuration: dragDuration, thenDragTo: destinationCoordinate)
                    case "typeText":
                        let text = String(message_debug.split(separator: ":")[3])
                        app.typeText(text)
                    default:
                        print("Unknown action: \(action)")
                    }
                }
            }
            
              }
              sock.disconnectAfterWriting()
    }
    
}
