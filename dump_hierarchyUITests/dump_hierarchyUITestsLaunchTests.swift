import XCTest
import CocoaAsyncSocket
import Foundation
import UIKit
import ObjectiveC.runtime

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
    var cachedElement: XCUIElement? // 新增：全局缓存变量，永远存储最后一个元素
    var listenThread: Thread!
    var listenSocket: GCDAsyncSocket!
    var connectedSockets = [GCDAsyncSocket]()
    var testExpectation: XCTestExpectation?
    var expectations: [XCTestExpectation] = []
    var element_dict = [String: XCUIElement]()
    var isRecording = false
    var images: [UIImage] = []
    var condi = XCUIApplication(bundleIdentifier: "com.apple.springboard").coordinate(withNormalizedOffset: .zero)

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        listenThread = Thread(target: self, selector: #selector(startServer), object: nil)
        listenThread.start()
        let savedIP = UserDefaults.standard.string(forKey: "ServerIP") ?? "0.0.0.0"
        print(savedIP)
        let
        cond = XCUIApplication().coordinate(withNormalizedOffset: .zero)

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
        wait(for: expectations, timeout: 99990.0)
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
                responseBody = handleGetCurrentBundleIdentifier()[0]
            } else if command.contains("get_jpg_pic") {
                let response = handleGetJPGPic(params)
                sendHTTPResponse(response, socket: socket)
                return
            } else if command.contains("find_element_by_query") {
                responseBody = handleFindElementByQuery(params)
            } else if command.contains("element_action") {
                handleElementAction(params)
                responseBody = "Element action performed"
            } else if command.contains("coordinate_action") {
                handleCoordinateAction(params)
                responseBody = "Coordinate action performed"
            } else if command.contains("device_action") {
                handleDeviceAction(params)
                responseBody = "Device action performed"
            } else if command.contains("device_info") {
                responseBody = handleDeviceInfo(params)
            } else if command.contains("check_status") {
                responseBody = handleCheckStatus()
            
            }else if command.contains("element_tap") {
                responseBody = handleElementTap(params)
            }else if command.contains("press"){
                if let xString = params["xPixel"],
                   let yString = params["yPixel"],
                   let xDouble = Double(xString),
                   let yDouble = Double(yString) {
                    handleApress(condi: condi ,x: xDouble, y: yDouble)
                }
                
            }
            else if command.contains("tap"){
                if let xString = params["xPixel"],
                   let yString = params["yPixel"],
                   let xDouble = Double(xString),
                   let yDouble = Double(yString) {

                    let scale = UIScreen.main.scale
                    let xPoint = CGFloat(xDouble)
                    let yPoint = CGFloat(yDouble)
                    debugClassMethods(className: "XCPointerEventPath")


                    let rst = performTap2(at: CGPoint(x: xPoint, y: yPoint))
                    print(rst)
                }

            }

            else if command == "save_ip" {
                guard let ip = params["ip"] else {
                    responseBody = "缺少 IP 参数"
                    return
                }
                UserDefaults.standard.set(ip, forKey: "ServerIP")
                responseBody = "IP 地址已保存：\(ip)"
            }

            else {
                let errorMessage = "HTTP/1.1 404 Not Found\r\n\r\n".data(using: .utf8) ?? Data()
                sendHTTPResponse((404, ["Content-Type": "text/plain", "Content-Length": "\(errorMessage.count)"], errorMessage), socket: socket)
                return
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
    private var currentOffset: Double = 0.1




    func performTap2(at point: CGPoint) -> Bool {
        guard let eventPathClass = NSClassFromString("XCPointerEventPath") as? NSObject.Type,
              let eventRecordClass = NSClassFromString("XCSynthesizedEventRecord") as? NSObject.Type else {
            print("无法找到相关类")
            return false
        }
        
        let pointValue = NSValue(cgPoint: point)
        let x = point.x
        let y = point.y
        let initialOffset = point.x
        let pressOffset = 0.3
        let liftOffset = 2.4
        
        // 1. alloc eventPath
        guard let eventPathAlloc = eventPathClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as? NSObject else {
            print("eventPath alloc失败")
            return false
        }
        
        // 2. 使用 objc_msgSend 调用 initForTouchAtPoint:offset:
        typealias InitFunc = @convention(c) (NSObject, Selector, NSValue, Double,Double) -> NSObject?
        
        let selector = NSSelectorFromString("initForTouchAtPoint:offset:")
        let imp = eventPathAlloc.method(for: selector)
        let curriedInit = unsafeBitCast(imp, to: InitFunc.self)
        
        guard let eventPath = curriedInit(eventPathAlloc, selector, pointValue, x,y) else {
            print("eventPath init失败")
            return false
        }
        
        // 3. pressDownAtOffset:
//        if eventPath.responds(to: NSSelectorFromString("pressDownAtOffset:")) {
//            let sel = NSSelectorFromString("pressDownAtOffset:")
//            let imp2 = eventPath.method(for: sel)
//            typealias PressFunc = @convention(c) (NSObject, Selector, Double) -> Void
//            let func2 = unsafeBitCast(imp2, to: PressFunc.self)
//            func2(eventPath, sel, pressOffset)
//        } else {
//            print("不支持 pressDownAtOffset:")
//            return false
//        }
        
        // 4. liftUpAtOffset:
        if eventPath.responds(to: NSSelectorFromString("liftUpAtOffset:")) {
            let sel = NSSelectorFromString("liftUpAtOffset:")
            let imp2 = eventPath.method(for: sel)
            typealias LiftFunc = @convention(c) (NSObject, Selector, Double) -> Void
            let func2 = unsafeBitCast(imp2, to: LiftFunc.self)
            func2(eventPath, sel, liftOffset)
        } else {
            print("不支持 liftUpAtOffset:")
            return false
        }
        
        // 5. 创建事件记录
        guard let eventRecordAlloc = eventRecordClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as? NSObject else {
            print("eventRecord alloc失败")
            return false
        }
        
        // 6. initWithName:interfaceOrientation:
        let initSel = NSSelectorFromString("initWithName:interfaceOrientation:")
        guard let eventRecord = eventRecordAlloc.perform(initSel, with: "Tap Event", with: NSNumber(value: 1))?.takeUnretainedValue() as? NSObject else {
            print("eventRecord init失败")
            return false
        }
        
        // 7. addPointerEventPath:
        if eventRecord.responds(to: NSSelectorFromString("addPointerEventPath:")) {
            eventRecord.perform(NSSelectorFromString("addPointerEventPath:"), with: eventPath)
        } else {
            print("不支持 addPointerEventPath:")
            return false
        }
        
        // 8. synthesizeWithError:
        let synthSel = NSSelectorFromString("synthesizeWithError:")
            if eventRecord.responds(to: synthSel) {
                var error: NSError? = nil
                typealias SynthFunc = @convention(c) (AnyObject, Selector, UnsafeMutablePointer<NSError?>?) -> Bool
                let imp = eventRecord.method(for: synthSel)!
                let synthFunc = unsafeBitCast(imp, to: SynthFunc.self)
                let success = synthFunc(eventRecord, synthSel, &error)
                if success {
                    print("触摸事件成功发送")
                    return true
                } else {
                    print("触摸事件发送失败: \(error?.localizedDescription ?? "未知错误")")
                    return false
                }
            } else {
                print("不支持 synthesizeWithError:")
                return false
            }
    }
    



    
    func synthesizeTap(at point: CGPoint) {
        printPrivateClassProperties(className: "XCPointerEvent")

        // 1. 动态获取类
        guard let eventRecordClass = NSClassFromString("XCSynthesizedEventRecord") as? NSObject.Type,
              let pointerEventPathClass = NSClassFromString("XCPointerEventPath") as? NSObject.Type,
              let pointerEventClass = NSClassFromString("XCPointerEvent") as? NSObject.Type else {
            print("无法加载XCTest私有类")
            return
        }
        

        // 调试输出：确认坐标
        print("尝试点击坐标: \(point)")
        print("屏幕尺寸: \(UIScreen.main.bounds.size)")
        let scale = UIScreen.main.scale
        print(scale)
        let validPoint = CGPoint(
            x: point.x,
            y: point.y
        )


        
        // 2. 创建事件路径
        let eventPath = pointerEventPathClass.init()
        
        // 3. 创建完整的触摸周期（按下+抬起）
        let pointerEvents = NSMutableArray()
        
        // 按下事件
//        let beginEvent = pointerEventClass.init()
//        beginEvent.setValue(validPoint, forKeyPath: "coordinate")
//        beginEvent.setValue(0.0, forKeyPath: "offset")           // 起始时间为 0.0
//        beginEvent.setValue(1, forKeyPath: "gesturePhase")       // 1 = began
//        beginEvent.setValue(1, forKeyPath: "eventType")          // 1 = touch
//        beginEvent.setValue(1, forKeyPath: "clickCount")         // 单击
//        beginEvent.setValue(1, forKeyPath: "gestureStage")
//// 单击
//        pointerEvents.add(beginEvent)
        
//        // 抬起事件（延迟50ms模拟真实触摸）
        let endEvent = pointerEventClass.init()
        endEvent.setValue(validPoint, forKeyPath: "coordinate")
        endEvent.setValue(0.0, forKeyPath: "offset")           // 0.05秒后抬起
        endEvent.setValue(2, forKeyPath: "gesturePhase")        // 2 = ended
        endEvent.setValue(1, forKeyPath: "eventType")           // 1 = touch
       
//// 单击
//
//        // ⚠️ 不再设置 clickCount
        pointerEvents.add(endEvent)
//
        let endEvent2 = pointerEventClass.init()
        endEvent2.setValue(validPoint, forKeyPath: "coordinate")
        endEvent2.setValue(3, forKeyPath: "offset")           // 0.05秒后抬起
        endEvent2.setValue(2, forKeyPath: "gesturePhase")        // 2 = ended
        endEvent2.setValue(3, forKeyPath: "eventType")           // 1 = touch
     
////// 单击
//
//        // ⚠️ 不再设置 clickCount
        pointerEvents.add(endEvent2)
        
        // 设置事件路径
        eventPath.setValue(pointerEvents, forKey: "pointerEvents")
        
        // 4. 初始化事件记录
        let eventRecord = eventRecordClass.init()
        eventRecord.setValue([eventPath], forKey: "eventPaths")
        
        // 5. 触发事件
        let selector = NSSelectorFromString("synthesizeWithError:")
        if eventRecord.responds(to: selector) {
            var error: NSError?
            eventRecord.perform(selector, with: nil)
            
            if let error = error {
                print("合成事件失败: \(error.localizedDescription)")
            } else {
                print("✅ 事件合成成功")
            }
        } else {
            print("synthesizeWithError: 方法不存在")
        }
    }
    func printPrivateClassProperties(className: String) {
        // 1. 获取类对象
        guard let cls = NSClassFromString(className) as? NSObject.Type else {
            print("❌ 类 \(className) 不存在")
            return
        }
        
        // 2. 获取属性列表
        var propertyCount: UInt32 = 0
        let properties = class_copyPropertyList(cls, &propertyCount)
        
        if let properties = properties {
            print("\n=== \(className) 属性列表 ===")
            for i in 0..<Int(propertyCount) {
                let property = properties[i]
                let propertyName = String(cString: property_getName(property))
                print("  - \(propertyName)")
            }
            free(properties) // 释放内存
        } else {
            print("❌ 无法获取属性列表")
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
        guard let bundle_id = params["c"] else { return }
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

    private func handleGetCurrentBundleIdentifier() -> [String] {
        guard let workspace = NSClassFromString("LSApplicationWorkspace") as? NSObject,
                  let workspaceInstance = workspace.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject,
                  let apps = workspaceInstance.perform(Selector(("allInstalledApplications")))?.takeUnretainedValue() as? [AnyObject] else {
                return []
            }
            
            return apps.compactMap { app in
                app.perform(Selector(("bundleIdentifier")))?.takeUnretainedValue() as? String
            }
    }


    

//        let ios_system_bundle_identifiers = [
//            "com.apple.Preferences",
//            "com.apple.mobilephone",
//            "com.apple.MobileSMS",
//            "com.apple.camera",
//            "com.apple.mobileslideshow",
//            "com.apple.mobilemail",
//            "com.apple.mobilesafari",
//            "com.apple.mobilecal",
//            "com.apple.reminders",
//            "com.apple.mobilenotes",
//            "com.apple.Music",
//            "com.apple.Maps",
//            "com.apple.InCallService",
//            "com.apple.springboard"
//        ]
//        var response = "No frontmost app found"
//        if let bundle_idsString = params["bundle_ids"] {
//            let bundle_ids = bundle_idsString.components(separatedBy: ",") + ios_system_bundle_identifiers
//            for bundleId in bundle_ids {
//                let app = XCUIApplication(bundleIdentifier: bundleId)
//                if app.state == .runningForeground {
//                    response = bundleId
//                    break
//                }
//            }
//        }
//        return response
//    }

    private func handleGetJPGPic(_ params: [String: String]) -> (statusCode: Int, headers: [String: String], body: Data) {
        guard let compressionQualityString = params["compression_quality"] else {
            return (400, ["Content-Type": "text/plain"], Data("error format".utf8))
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var result = (400, ["Content-Type": "text/plain"], Data())
        
        DispatchQueue.global(qos: .userInitiated).async {
            let screenshot = XCUIScreen.main.screenshot()
            if let quality = Double(compressionQualityString),
               let jpegData = screenshot.image.jpegData(compressionQuality: CGFloat(quality)) {
                result = (200, ["Content-Type": "image/jpeg"], jpegData)
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5.0) // 5秒超时
        return result
    }

    private func handleFindElementByQuery(_ params: [String: String]) -> String {
        guard let bundle_id = params["bundle_id"]?.removingPercentEncoding,
              let query_method = params["query_method"]?.removingPercentEncoding,
              let query_value = params["query_value"]?.removingPercentEncoding else {
            return "Missing parameters"
        }
        print(query_value)
        let app = XCUIApplication(bundleIdentifier: bundle_id)
        let FindElement = FindElement(app: app)
        let element = FindElement.find_element_by_query(query_method: query_method, query_value: query_value)
        var responseData = ""
        if !element.exists {
            cachedElement = nil
            return responseData
        }
        cachedElement = element
        print("Element cached: \(element)") // 打印缓存更新日志

        do {
            responseData = try element.snapshotToString()
        } catch {
            print("Error converting element snapshot to string: \(error)")
        }
        return responseData
    }

    private func handleElementAction(_ params: [String: String]) {
        guard let bundle_id = params["bundle_id"], let action = params["action"], let action_parms = params["action_parms"], let query_method = params["query_method"], let query_value = params["query_value"] else { return }
        let app = XCUIApplication(bundleIdentifier: bundle_id)
        var element: XCUIElement
        let FindElement = FindElement(app: app)
        let key = "\(bundle_id)|\(action)|\(action_parms)|\(query_method)|\(query_value)"
        if let current_element = element_dict[key] {
            print("Found element: \(current_element)")
            element = current_element
        } else {
            element = FindElement.find_element_by_query(query_method: query_method, query_value: query_value)
        }
        let xPixel = element.frame.origin.x + element.frame.size.width / 2
        let yPixel = element.frame.origin.y + element.frame.size.height / 2
        let ElementAction = ElementAction(app: app, xPixel: xPixel, yPixel: yPixel, action_parms: action_parms)
        ElementAction.perform_action(action: action)
    }
    
    private func handleApress(condi:XCUICoordinate,x:Double,y:Double){
        condi.withOffset(CGVector(dx: x, dy: y)).tap()
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
    
    func debugClassMethods(className: String) {
        guard let targetClass = NSClassFromString(className) else {
            print("类 \(className) 不存在")
            return
        }
        
        var methodCount: UInt32 = 0
        let methods = class_copyMethodList(targetClass, &methodCount)
        
        print("类 \(className) 的可用方法:")
        for i in 0..<Int(methodCount) {
            if let method = methods?[i] {
                let methodName = NSStringFromSelector(method_getName(method))
                print("- \(methodName)")
            }
        }
        
        free(methods)
    }

}
