import XCTest
import CocoaAsyncSocket
import Foundation
import UIKit

enum SomeError: Error {
    case StringConversionFailed
}

extension XCUIElement {
    func snapshotToString() -> String {
        let response = try! self.snapshot().dictionaryRepresentation
        let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            fatalError("String conversion failed")
        }
        return jsonString
    }
}



class MyServerTests: XCTestCase,GCDAsyncSocketDelegate  {
    var listenThread: Thread!
    var listenSocket: GCDAsyncSocket!
    var connectedSockets = [GCDAsyncSocket]()
    var testExpectation: XCTestExpectation?
    var expectations: [XCTestExpectation] = []
    var element_dict = [String: XCUIElement]()

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
            
            if message.contains("find_elements_by_query"){
                var element_info_list: [String] = []
                let bundle_id = String(message.split(separator: ":")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                let condition = String(message.split(separator: ":")[2]).trimmingCharacters(in: .whitespacesAndNewlines)
                let app = XCUIApplication(bundleIdentifier: String(bundle_id))
                let predicate = NSPredicate(format: condition)
                let elements = app.descendants(matching: .any).matching(predicate)
                for i in 0..<elements.count {
                    let element = elements.element(boundBy: i)
                    element_info_list.append(element.snapshotToString())
                }
                let combinedString = element_info_list.joined(separator: ", ")
                if let responseData = combinedString.data(using: .utf8) {
                    sock.write(responseData, withTimeout: -1, tag: 0)
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
    
            if message.contains("find_element_by_query"){
                var element:XCUIElement
               
                let bundle_id = String(message.split(separator: ":")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                let query_method = String(message.split(separator: ":")[2]).trimmingCharacters(in: .whitespacesAndNewlines)
                let query_value = String(message.split(separator: ":")[3]).trimmingCharacters(in: .whitespacesAndNewlines)
                let app = XCUIApplication(bundleIdentifier:String(bundle_id))
                let FindElement = FindElement(app:app)
                element = XCUIApplication()
                element = FindElement.find_element_by_query(query_method:query_method,query_value:query_value)
                
                var  responseData = ""
                if !element.exists {
                    sock.write(responseData.data(using: .utf8), withTimeout: -1, tag: 0)
                }else{
                    responseData = element.snapshotToString()
                    sock.write(responseData.data(using: .utf8), withTimeout: -1, tag: 0)
                }
            }
            if message.contains("element_action"){
                let bundle_id = String(message.split(separator: ":")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                let app = XCUIApplication(bundleIdentifier:String(bundle_id))
                let action = String(message.split(separator: ":")[2]).trimmingCharacters(in: .whitespacesAndNewlines)
                let action_parms = String(message.split(separator: ":")[3]).trimmingCharacters(in: .whitespacesAndNewlines)
                let query_method = String(message.split(separator: ":")[4]).trimmingCharacters(in: .whitespacesAndNewlines)
                let query_value = String(message.split(separator: ":")[5]).trimmingCharacters(in: .whitespacesAndNewlines)
                var element:XCUIElement
                let FindElement = FindElement(app:app)

                if let current_element = element_dict[message]{
                    print("Found element: \(current_element)")
                    element = current_element
                }
                else{
                    element = FindElement.find_element_by_query(query_method: query_method,query_value:query_value)
                }
                let xPixel  = element.frame.origin.x + element.frame.size.width / 2
                let yPixel = element.frame.origin.y + element.frame.size.height / 2
                let ElementAction = ElementAction(app:app,xPixel:xPixel,yPixel:yPixel,action_parms:action_parms)
                ElementAction.perform_action(action: action)

                
            }
            if message.contains("coordinate_action") {
                let message_debug = message.trimmingCharacters(in: .whitespacesAndNewlines)
                let bundle_id = message_debug.split(separator: ":")[1]
                print(bundle_id + "is the bundle id")
                let app = XCUIApplication(bundleIdentifier: String(bundle_id))
                let action = message_debug.split(separator: ":")[2]
                let xPixel = CGFloat(Float(message_debug.split(separator: ":")[3]) ?? 0.0)
                let yPixel = CGFloat(Float(message_debug.split(separator: ":")[4]) ?? 0.0)
                let action_parms = String(message.split(separator: ":")[5]).trimmingCharacters(in: .whitespacesAndNewlines)
                let ElementAction = ElementAction(app:app,xPixel:xPixel,yPixel:yPixel,action_parms:action_parms)
                ElementAction.perform_action(action: String(action))
            }
            if message.contains("device_action") {
                let message_debug = message.trimmingCharacters(in: .whitespacesAndNewlines)
                let action = message_debug.split(separator: ":")[1]
                let DeviceAction = DeviceAction()
                DeviceAction.perform_action(action: String(action))
            }
            
              }
              sock.disconnectAfterWriting()
    }
    
}
