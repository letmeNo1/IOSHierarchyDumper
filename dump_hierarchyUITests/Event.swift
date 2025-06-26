import XCTest

private class XCEventHelper {
    static func createEventPath(at point: CGPoint, x: Double, y: Double) -> NSObject? {
        guard let eventPathClass = NSClassFromString("XCPointerEventPath") as? NSObject.Type else {
            print("无法找到 XCPointerEventPath 类")
            return nil
        }
        
        guard let eventPathAlloc = eventPathClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as? NSObject else {
            print("eventPath alloc失败")
            return nil
        }
        
        let pointValue = NSValue(cgPoint: point)
        let selector = NSSelectorFromString("initForTouchAtPoint:offset:")
        let imp = eventPathAlloc.method(for: selector)
        typealias InitFunc = @convention(c) (NSObject, Selector, NSValue, Double, Double) -> NSObject?
        let curriedInit = unsafeBitCast(imp, to: InitFunc.self)
        
        return curriedInit(eventPathAlloc, selector, pointValue, x, y)
    }
    
    static func createEventRecord(name: String) -> NSObject? {
        guard let eventRecordClass = NSClassFromString("XCSynthesizedEventRecord") as? NSObject.Type else {
            print("无法找到 XCSynthesizedEventRecord 类")
            return nil
        }
        
        guard let eventRecordAlloc = eventRecordClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as? NSObject else {
            print("eventRecord alloc失败")
            return nil
        }
        
        let initSel = NSSelectorFromString("initWithName:interfaceOrientation:")
        return eventRecordAlloc.perform(initSel, with: name, with: NSNumber(value: 1))?.takeUnretainedValue() as? NSObject
    }
    
    static func synthesizeEvent(_ eventRecord: NSObject, _ eventPath: NSObject) -> Bool {
        guard eventRecord.responds(to: NSSelectorFromString("addPointerEventPath:")) else {
            print("不支持 addPointerEventPath:")
            return false
        }
        
        eventRecord.perform(NSSelectorFromString("addPointerEventPath:"), with: eventPath)
        
        let synthSel = NSSelectorFromString("synthesizeWithError:")
        guard eventRecord.responds(to: synthSel) else {
            print("不支持 synthesizeWithError:")
            return false
        }
        
        var error: NSError? = nil
        typealias SynthFunc = @convention(c) (AnyObject, Selector, UnsafeMutablePointer<NSError?>?) -> Bool
        let imp = eventRecord.method(for: synthSel)!
        let synthFunc = unsafeBitCast(imp, to: SynthFunc.self)
        let success = synthFunc(eventRecord, synthSel, &error)
        
        if success {
            print("事件成功发送")
            return true
        } else {
            print("事件发送失败: \(error?.localizedDescription ?? "未知错误")")
            return false
        }
    }
}

class TouchActionExecutor {
    private let xPixel: Double
    private let yPixel: Double
    private let x2Pixel: Double?
    private let y2Pixel: Double?
    private let duration: Double
    
    init(xPixel: Double, yPixel: Double, x2Pixel: Double? = nil, y2Pixel: Double? = nil, duration: Double = 0.5) {
        self.xPixel = xPixel
        self.yPixel = yPixel
        self.x2Pixel = x2Pixel
        self.y2Pixel = y2Pixel
        self.duration = duration
    }
    
    func perform(action: String) -> Bool {
        let point = CGPoint(x: xPixel, y: yPixel)
        
        switch action {
        case "tap":
            return tap(at: point)
        case "longPress":
            return press(at: point, durtion: duration)
        case "move":
            guard let x2 = x2Pixel, let y2 = y2Pixel else {
                print("移动操作需要提供目标坐标")
                return false
            }
            let endPoint = CGPoint(x: x2, y: y2)
            return move(at: point, moveTo: endPoint, duration: duration)
        default:
            print("Unknown action: \(action)")
            return false
        }
        
    }
}
  
// 优化后的函数
func tap(at point: CGPoint) -> Bool {
    let x = point.x
    let y = point.y
    let pressOffset = 0.1
    
    guard let eventPath = XCEventHelper.createEventPath(at: point, x: x, y: y) else {
        print("eventPath init失败")
        return false
    }
    
    // pressDownAtOffset:
    if eventPath.responds(to: NSSelectorFromString("pressDownAtOffset:")) {
        let sel = NSSelectorFromString("pressDownAtOffset:")
        let imp2 = eventPath.method(for: sel)
        typealias PressFunc = @convention(c) (NSObject, Selector, Double) -> Void
        let func2 = unsafeBitCast(imp2, to: PressFunc.self)
        func2(eventPath, sel, pressOffset)
    } else {
        print("不支持 pressDownAtOffset:")
        return false
    }
    
    guard let eventRecord = XCEventHelper.createEventRecord(name: "Tap Event") else {
        print("eventRecord init失败")
        return false
    }
    
    return XCEventHelper.synthesizeEvent(eventRecord, eventPath)
}

func press(at point: CGPoint, durtion: Double) -> Bool {
    let x = point.x
    let y = point.y
    let pressOffset = durtion
    
    guard let eventPath = XCEventHelper.createEventPath(at: point, x: x, y: y) else {
        print("eventPath init失败")
        return false
    }
    
    // pressDownAtOffset:
    if eventPath.responds(to: NSSelectorFromString("pressDownAtOffset:")) {
        let sel = NSSelectorFromString("pressDownAtOffset:")
        let imp2 = eventPath.method(for: sel)
        typealias PressFunc = @convention(c) (NSObject, Selector, Double) -> Void
        let func2 = unsafeBitCast(imp2, to: PressFunc.self)
        func2(eventPath, sel, pressOffset)
    } else {
        print("不支持 pressDownAtOffset:")
        return false
    }
    
    guard let eventRecord = XCEventHelper.createEventRecord(name: "Tap Event") else {
        print("eventRecord init失败")
        return false
    }
    
    return XCEventHelper.synthesizeEvent(eventRecord, eventPath)
}

func move(at startPoint: CGPoint, moveTo endPoint: CGPoint, duration: Double) -> Bool {
    let x = startPoint.x
    let y = startPoint.y
    let x2 = endPoint.x
    let y2 = endPoint.y
    guard let eventPath = XCEventHelper.createEventPath(at: startPoint, x: x, y: y) else {
        print("eventPath init失败")
        return false
    }
    
    // 添加移动到操作
    if eventPath.responds(to: NSSelectorFromString("moveToPoint:atOffset:")) {
        let moveSelector = NSSelectorFromString("moveToPoint:atOffset:")
        let moveImp = eventPath.method(for: moveSelector)
        typealias MoveFunc = @convention(c) (NSObject, Selector, NSValue, Double,Double,Double) -> Void
        let moveFunction = unsafeBitCast(moveImp, to: MoveFunc.self)
        
        let endPointValue = NSValue(cgPoint: endPoint)
        let moveOffset = duration * 0.75
        moveFunction(eventPath, moveSelector, endPointValue, x2,y2,moveOffset)
    } else {
        print("不支持 moveToPoint:atOffset:")
        return false
    }
    
    // 设置抬起时间
//    if eventPath.responds(to: NSSelectorFromString("liftUpAtOffset:")) {
//        let liftSelector = NSSelectorFromString("liftUpAtOffset:")
//        let liftImp = eventPath.method(for: liftSelector)
//        typealias LiftFunc = @convention(c) (NSObject, Selector, Double) -> Void
//        let liftFunction = unsafeBitCast(liftImp, to: LiftFunc.self)
//        liftFunction(eventPath, liftSelector, duration)
//    } else {
//        print("不支持 liftUpAtOffset:")
//        return false
//    }
//    
    guard let eventRecord = XCEventHelper.createEventRecord(name: "Drag Event") else {
        print("eventRecord init失败")
        return false
    }
    
    return XCEventHelper.synthesizeEvent(eventRecord, eventPath)
}
