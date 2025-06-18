import XCTest
import CocoaAsyncSocket
import Foundation
import UIKit

enum SomeError: Error {
    case stringConversionFailed
}

extension XCUIElement {
    func snapshotToString() throws -> String {
        let response = try self.snapshot().dictionaryRepresentation
        let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw SomeError.stringConversionFailed
        }
        return jsonString
    }
}

class MyServerTests: XCTestCase, GCDAsyncSocketDelegate {
    var listenThread: Thread!
    var listenSocket: GCDAsyncSocket!
    var connectedSockets = [GCDAsyncSocket]()
    var testExpectation: XCTestExpectation?
    var expectations: [XCTestExpectation] = []
    var element_dict = [String: XCUIElement]()
    var isRecording = false
    var images: [UIImage] = []

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        listenThread = Thread(target: self, selector: #selector(startServer), object: nil)
        listenThread.start()
        print("Listening on port ")
        Thread.sleep(forTimeInterval: 1.0)
    }

    override func tearDown() {
        for expectation in expectations {
            expectation.fulfill()
        }
        super.tearDown()
        listenSocket.disconnect()
        listenSocket = nil
        listenThread.cancel()
    }

    func testClienth() {
        for i in 0..<100 {
            let expectation = XCTestExpectation(description: "Receive response from server \(i)")
            expectations.append(expectation)
        }
        wait(for: expectations, timeout: 999990.0)
    }

    @objc func startServer() {
        var customValueInt: UInt16 = 8200
        listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            if let customValueString = ProcessInfo.processInfo.environment["USE_PORT"] {
                customValueInt = UInt16(customValueString) ?? 8200
                print("The value of USE_PORT is: \(customValueString)")
            } else {
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
            handleHTTPRequest(message, socket: sock)
        }
        sock.disconnectAfterWriting()
    }

    private func handleHTTPRequest(_ request: String, socket: GCDAsyncSocket) {
        let lines = request.components(separatedBy: "\r\n")
        let firstLine = lines.first?.components(separatedBy: " ")
        guard let method = firstLine?[0], let path = firstLine?[1] else {
            let statusCode = 400
            let headers = ["Content-Type": "text/plain"]
            let errorMessage = "HTTP/1.1 400 Bad Request\r\n\r\n"
            let body = errorMessage.data(using: .utf8) ?? Data()
            sendHTTPResponse((statusCode, headers, body), socket: socket)
            return
        }

        if method == "GET" {
            let components = path.components(separatedBy: "?")
            let command = components[0].trimmingCharacters(in: .init(charactersIn: "/"))
            var params = [String: String]()
            if components.count > 1 {
                params = parseQueryParams(components[1])
            }

            var responseBody = ""
            if command.contains("dump_tree") {
                responseBody = handleDumpTree(params)
            } else if command.contains("activate_app") {
                handleActivateApp(params)
                responseBody = "App activated"
            } else if command.contains("terminate_app") {
                handleTerminateApp(params)
                responseBody = "App terminated"
            } else if command.contains("start_recording") {
                handleStartRecording()
                responseBody = "Recording started"
            } else if command.contains("stop_recording") {
                let responseData = handleStopRecording()
                   socket.write(responseData, withTimeout: -1, tag: 0)
                   return
            } else if command.contains("get_actual_wh") {
                responseBody = handleGetActualWH()
            
            } else if command.contains("get_png_pic") {
                responseBody = "PNG picture data"
            } else if command.contains("find_elements_by_query") {
                responseBody = handleFindElementsByQuery(params)
            } else if command.contains("get_current_bundleIdentifier") {
                responseBody = handleGetCurrentBundleIdentifier(params)
            } else if command.contains("get_jpg_pic") {
                let response = handleGetJPGPic(params)
                sendHTTPResponse(response, socket: socket)
                return
            } else if command.contains("find_element_by_query") {
                responseBody = handleFindElementByQuery(params)
            }  else if command.contains("coordinate_action") {
                handleCoordinateAction(params)
                responseBody = "Coordinate action performed"
            } else if command.contains("device_action") {
                handleDeviceAction(params)
                responseBody = "Device action performed"
            } else if command.contains("device_info") {
                responseBody = handleDeviceInfo(params)
            } else if command.contains("check_status") {
                responseBody = handleCheckStatus()
            } else {
                let errorMessage = "HTTP/1.1 404 Not Found\r\n\r\n".data(using: .utf8) ?? Data()
                sendHTTPResponse((404, ["Content-Type": "text/plain", "Content-Length": "\(errorMessage.count)"], errorMessage), socket: socket)
                return
            }else if command.contains("event") {
                handleEventAction(params)
                responseBody = "Event action performed"
            }

            let responseData = responseBody.data(using: .utf8) ?? Data()
            sendHTTPResponse((200, ["Content-Type": "text/plain", "Content-Length": "\(responseData.count)"], responseData), socket: socket)
        } else {
            let errorMessage = "HTTP/1.1 405 Method Not Allowed\r\n\r\n".data(using: .utf8) ?? Data()
            sendHTTPResponse((405, ["Content-Type": "text/plain", "Content-Length": "\(errorMessage.count)"], errorMessage), socket: socket)
        }
    }

    private func sendHTTPResponse(_ response: (statusCode: Int, headers: [String: String], body: Data), socket: GCDAsyncSocket) {
        var responseString = "HTTP/1.1 \(response.statusCode) "
        switch response.statusCode {
        case 200:
            responseString += "OK"
        case 400:
            responseString += "Bad Request"
        default:
            responseString += "Unknown Status"
        }
        responseString += "\r\n"

        for (key, value) in response.headers {
            responseString += "\(key): \(value)\r\n"
        }
        responseString += "\r\n"

        if let responseData = responseString.data(using: .utf8) {
            let finalData = responseData + response.body
            socket.write(finalData, withTimeout: -1, tag: 0)
        }
    }

    private func parseQueryParams(_ paramString: String) -> [String: String] {
        var params = [String: String]()
        let pairs = paramString.components(separatedBy: "&")
        for pair in pairs {
            let keyValue = pair.components(separatedBy: "=")
            if keyValue.count == 2 {
                let decodedKey = keyValue[0].replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? ""
                let decodedValue = keyValue[1].replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? ""
                params[decodedKey] = decodedValue
            }
        }
        return params
    }

    private func handleDumpTree(_ params: [String: String]) -> String {
        guard let bundle_id = params["bundle_id"] else { return "Missing bundle_id parameter" }
        let app = XCUIApplication(bundleIdentifier: bundle_id)
        return app.debugDescription
    }

    private func handleActivateApp(_ params: [String: String]) {
        guard let bundle_id = params["bundle_id"] else { return }
        let app = XCUIApplication(bundleIdentifier: bundle_id)
        app.activate()
    }

    private func handleTerminateApp(_ params: [String: String]) {
        guard let bundle_id = params["bundle_id"] else { return }
        let app = XCUIApplication(bundleIdentifier: bundle_id)
        app.terminate()
    }
    
    
    func handleStartRecordingRequest() -> Data {
            // 检查是否已有录制正在进行
            if isRecording {
                let statusCode = 400
                let headers = ["Content-Type": "text/plain"]
                // 将 let 改为 var，使 errorMessage 成为可变变量
                var errorMessage = "HTTP/1.1 \(statusCode) Bad Request\r\n"
                for (key, value) in headers {
                    errorMessage += "\(key): \(value)\r\n"
                }
                errorMessage += "\r\nRecording is already in progress"
                return errorMessage.data(using: .utf8)!
            }
            
            // 调用实际的录制启动方法
            handleStartRecording()
            
            // 返回成功响应
            let statusCode = 200
            let headers = ["Content-Type": "text/plain"]
            // 将 let 改为 var，使 successMessage 成为可变变量
            var successMessage = "HTTP/1.1 \(statusCode) OK\r\n"
            for (key, value) in headers {
                successMessage += "\(key): \(value)\r\n"
            }
            successMessage += "\r\nRecording started successfully"
            return successMessage.data(using: .utf8)!
        }
        
    private func handleStartRecording() {
       isRecording = true
       images = []
       var screenshotCount = 0
       let maxScreenshots = 600

       DispatchQueue.global(qos: .background).async { [weak self] in
           guard let self = self else { return }
           while self.isRecording && screenshotCount < maxScreenshots {
               DispatchQueue.main.async {
                   let screenshot = XCUIScreen.main.screenshot()
                   let image = screenshot.image
                   self.images.append(image)
               }
               screenshotCount += 1
               usleep(200_000)
           }
       }
   }

    private func handleStopRecording() -> Data {
        guard isRecording else {
            let statusCode = 400
            let headers = ["Content-Type": "text/plain"]
            var errorMessage = "HTTP/1.1 \(statusCode) Bad Request\r\n"
            for (key, value) in headers {
                errorMessage += "\(key): \(value)\r\n"
            }
            errorMessage += "\r\nNo recording in progress"
            return errorMessage.data(using: .utf8)!
        }
        
        isRecording = false
        let imageDatas = images.compactMap { $0.jpegData(compressionQuality: 0.0) }
        
        // 构建 JSON 响应（Base64 编码的图片数组）
        let jsonData = try? JSONSerialization.data(withJSONObject: imageDatas.map { $0.base64EncodedString() })
        
        let statusCode = 200
        let headers = ["Content-Type": "application/json"]
        var responseString = "HTTP/1.1 \(statusCode) OK\r\n"
        for (key, value) in headers {
            responseString += "\(key): \(value)\r\n"
        }
        responseString += "\r\n"
        
        let finalData = responseString.data(using: .utf8)! + (jsonData ?? Data())
        return finalData
    }


    private func handleGetActualWH() -> String {
        let app = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let windowFrame = app.windows.element(boundBy: 0).frame
        let windowWidth = windowFrame.width
        let windowHeight = windowFrame.height
        return "\(windowWidth),\(windowHeight)"
    }

    private func handleFindElementsByQuery(_ params: [String: String]) -> String {
        guard let bundle_id = params["bundle_id"], let predicateExpression = params["predicate"] else {
            return "Missing parameters (bundle_id or predicate)"
        }

        var element_info_list: [String] = []
        let app = XCUIApplication(bundleIdentifier: bundle_id)

        do {
            let predicate = NSPredicate(format: predicateExpression)
            let elements = app.descendants(matching: .any).matching(predicate)

            for i in 0..<elements.count {
                let element = elements.element(boundBy: i)
                do {
                    let elementString = try element.snapshotToString()
                    element_info_list.append(elementString)
                } catch {
                    print("Error converting element snapshot to string: \(error)")
                }
            }
        }

        return element_info_list.joined(separator: ",")
    }

    private func handleGetCurrentBundleIdentifier(_ params: [String: String]) -> String {
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
            "com.apple.InCallService",
            "com.apple.springboard"
        ]
        var response = "No frontmost app found"
        if let bundle_idsString = params["bundle_ids"] {
            let bundle_ids = bundle_idsString.components(separatedBy: ",") + ios_system_bundle_identifiers
            for bundleId in bundle_ids {
                let app = XCUIApplication(bundleIdentifier: bundleId)
                if app.state == .runningForeground {
                    response = bundleId
                    break
                }
            }
        }
        return response
    }

    private func handleGetJPGPic(_ params: [String: String]) -> (statusCode: Int, headers: [String: String], body: Data) {
        guard let compressionQualityString = params["compression_quality"] else {
            let errorMessage = "error format".data(using: .utf8) ?? Data()
            return (400, ["Content-Type": "text/plain", "Content-Length": "\(errorMessage.count)"], errorMessage)
        }

        let screenshot = XCUIScreen.main.screenshot()
        let image = screenshot.image
        if let doubleValue = Double(compressionQualityString) {
            let compressionQuality = CGFloat(doubleValue)
            if let jpegData = image.jpegData(compressionQuality: compressionQuality) {
                return (200, ["Content-Type": "image/jpeg", "Content-Length": "\(jpegData.count)"], jpegData)
            }
        }

        let errorMessage = "error format".data(using: .utf8) ?? Data()
        return (400, ["Content-Type": "text/plain", "Content-Length": "\(errorMessage.count)"], errorMessage)
    }

    private func handleFindElementByQuery(_ params: [String: String]) -> String {
        
        guard let bundle_id = params["bundle_id"]?.removingPercentEncoding,
              let query_method = params["query_method"]?.removingPercentEncoding,
              let query_value = params["query_value"]?.removingPercentEncoding else {
            return "Missing parameters"
        }
        
        
        
        let app = XCUIApplication(bundleIdentifier: bundle_id)
        let FindElement = FindElement(app: app)
        
        // 处理可选返回值
        guard let element = FindElement.find_element_by_query(query_method: query_method, query_value: query_value) else {
            return ""
        }
        
        
        do {
            let responseData = try element.snapshotToString()
            return responseData
        } catch {
            return ""
        }
    }

    private func handleCoordinateAction(_ params: [String: String]) {
        guard let bundle_id = params["bundle_id"],
              let action = params["action"],
              let xPixelString = params["xPixel"],
              let yPixelString = params["yPixel"],
              let action_parms = params["action_parms"] else {
            return
        }

        print("\(bundle_id) is the bundle id")
        let app = XCUIApplication(bundleIdentifier: bundle_id)

        if let xFloat = Float(xPixelString),
           let yFloat = Float(yPixelString) {
            let xPixel = CGFloat(xFloat)
            let yPixel = CGFloat(yFloat)
            let ElementAction = ElementAction(app: app, xPixel: xPixel, yPixel: yPixel, action_parms: action_parms)
            ElementAction.perform_action(action: action)
        }
    }

    private func handleDeviceAction(_ params: [String: String]) {
        guard let action = params["action"] else { return }
        let DeviceAction = DeviceAction()
        DeviceAction.perform_action(action: action)
    }

    private func handleDeviceInfo(_ params: [String: String]) -> String {
        guard let value = params["value"] else { return "Missing value parameter" }
        let DeviceInfo = DeviceInfo()
        return DeviceInfo.get_info(value: value)
    }

    private func handleCheckStatus() -> String {
        return "server running"
    }
}
