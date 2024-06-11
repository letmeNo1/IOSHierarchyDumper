import XCTest

class DeviceAction {

    // 执行动作方法
    func perform_action(action: String) {
        let device = XCUIDevice.shared
        switch action {
        case "home":
            device.press(.home)
        case "volume_up":
            device.press(.volumeUp)
        case "volume_down":
            device.press(.volumeDown)


        default:
            print("Unknown action: \(action)")
        }
    }
    
}
