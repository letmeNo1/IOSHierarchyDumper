import XCTest

class ElementAction {
    // 定义元素属性
    var app: XCUIApplication
    var action_parms:[String]
    var coordinate: XCUICoordinate

    // 初始化方法
    init(app:XCUIApplication,xPixel: Double,yPixel: Double,action_parms:String) {
        self.action_parms = action_parms.split(separator: "_").map { String($0) }
        self.app = app
        let windowFrame = app.windows.element(boundBy: 0).frame
        let windowWidth = windowFrame.width
        let windowHeight = windowFrame.height
        let centerX = xPixel / windowWidth
        let centerY = yPixel / windowHeight
        self.coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: centerX, dy: centerY))
    }

    // 执行动作方法
    func perform_action(action: String) {
        switch action {
        case "click":
            self.coordinate.tap()
        case "double_click":
            self.coordinate.doubleClick()
        case "enter_text":
            // 输入文本示例
            let textToEnter = self.action_parms[0]
            self.app.typeText(textToEnter)
        case "clear_text":
            app.doubleTap()
            app.typeText(XCUIKeyboardKey.delete.rawValue)
        case "press":
            // 长按示例
            self.app.press(forDuration: Double(self.action_parms[0]) ?? 1.0)
        
        case "drag":
            // 拖拽示例
            let end = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: Double(self.action_parms[1]) ?? 1.0, dy: Double(self.action_parms[2]) ?? 0.0))
            self.coordinate.press(forDuration: Double(self.action_parms[0]) ?? 0.0, thenDragTo: end)
        case "swipe":
                let direction = self.action_parms[0] // 获取滑动方向，例如 "up", "down", "left", "right"
                switch direction {
                case "up":
                    // 滑动向上
                    let endCoordinate = coordinate.withOffset(CGVector(dx: 0.0, dy: -0.5))
                    coordinate.press(forDuration: 0.5, thenDragTo: endCoordinate)
                case "down":
                    // 滑动向下
                    let endCoordinate = coordinate.withOffset(CGVector(dx: 0.0, dy: 0.5))
                    coordinate.press(forDuration: 0.5, thenDragTo: endCoordinate)
                case "left":
                    // 滑动向左
                    let endCoordinate = coordinate.withOffset(CGVector(dx: -0.5, dy: 0.0))
                    coordinate.press(forDuration: 0.5, thenDragTo: endCoordinate)
                case "right":
                    // 滑动向右
                    let endCoordinate = coordinate.withOffset(CGVector(dx: 0.5, dy: 0.0))
                    coordinate.press(forDuration: 0.5, thenDragTo: endCoordinate)
            default:
                print("Unknown swipe direction: \(direction)")
            }
        default:
            print("Unknown action: \(action)")
        }
    }
}
