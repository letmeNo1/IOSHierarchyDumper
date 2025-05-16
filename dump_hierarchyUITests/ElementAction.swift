import XCTest

class ElementAction {
    // MARK: - 属性
    private(set) var app: XCUIApplication
    private(set) var action_parms: [String]
    private(set) var coordinate: XCUICoordinate
    
    // MARK: - 初始化
    init(app: XCUIApplication, xPixel: Double, yPixel: Double, action_parms: String) {
        self.app = app
        self.action_parms = action_parms.split(separator: "_").map(String.init)
        
        // 直接基于像素坐标创建基准点（不再使用标准化坐标）
        self.coordinate = app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: xPixel, dy: yPixel))
    }
    
    // MARK: - 公开方法
    func perform_action(action: String) {
        switch action {
        case "click":
            coordinate.tap()
        case "double_click":
            coordinate.doubleTap()
        case "enter_text":
            guard !action_parms.isEmpty else { return }
            app.typeText(action_parms[0])
        case "clear_text":
            app.doubleTap()
            app.typeText(XCUIKeyboardKey.delete.rawValue)
        case "press":
            let duration = Double(action_parms.first ?? "") ?? 1.0
            app.press(forDuration: duration)
        case "drag":
            performPixelBasedDrag()
        case "swipe":
            performSwipe()
        default:
            print("不支持的操作: \(action)")
        }
    }
    
    // MARK: - 私有方法
    private func performPixelBasedDrag() {
        // 参数格式: "持续时间_目标X像素_目标Y像素" (如图片中的 "0.5_0.8_0.2" 改为 "0.5_80_20")
        guard action_parms.count >= 3 else {
            print("需要3个参数: 持续时间_X像素偏移_Y像素偏移")
            return
        }
        
        let duration = Double(action_parms[0]) ?? 0.5
        let xOffset = Double(action_parms[1]) ?? 0
        let yOffset = Double(action_parms[2]) ?? 0
        print("""
                拖拽参数检查：
                起点坐标: \(coordinate.screenPoint)
                偏移量: dx=\(xOffset), dy=\(yOffset)
                """)
               
        // 创建基于像素偏移的目标坐标
        let endCoordinate = coordinate.withOffset(CGVector(dx: xOffset, dy: yOffset))
        
        // 执行拖拽（公共API）
        coordinate.press(forDuration: duration, thenDragTo: endCoordinate)
    }
    
    private func performSwipe() {
        guard let direction = action_parms.first else { return }
        
        // 固定像素偏移量（可根据需要调整）
        let offset: CGVector
        switch direction {
        case "up":    offset = CGVector(dx: 0, dy: -100)  // 上滑100像素
        case "down":  offset = CGVector(dx: 0, dy: 100)   // 下滑100像素
        case "left":  offset = CGVector(dx: -100, dy: 0)  // 左滑100像素
        case "right": offset = CGVector(dx: 100, dy: 0)   // 右滑100像素
        default: return
        }
        
        let endCoordinate = coordinate.withOffset(offset)
        coordinate.press(forDuration: 0.5, thenDragTo: endCoordinate)
    }
}
