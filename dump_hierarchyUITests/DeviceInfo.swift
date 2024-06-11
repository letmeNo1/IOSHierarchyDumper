import XCTest
import AVFoundation

class DeviceInfo {

    // 执行动作方法
    func get_info(value: String) -> String {
        switch value {
        case "get_output_volume":
            let audioSession = AVAudioSession.sharedInstance()

            do {
                try audioSession.setActive(false)
                // 在这里可以进行其他操作，例如更新状态或释放资源

                try audioSession.setActive(true)
                // 重新激活音频会话
            } catch {
                print("Failed to set active state: \(error)")
            }
            let volume = audioSession.outputVolume
            
            print(volume)
            return String(volume)
            
        case "get_output_device_name":
            // 获取当前音频会话
            let audioSession = AVAudioSession.sharedInstance()
            // 获取当前音频路由
            let currentRoute = audioSession.currentRoute
            // 获取当前音频输出设备
            if let outputDevice = currentRoute.outputs.first {
                // 返回当前音频输出设备的名称
                return outputDevice.portName
            } else {
                // 如果没有找到音频输出设备，返回错误信息
                return "No output device found"
            }
            
        default:
//            print("Unknown value: \(value)")
            return "Unknown value: \(value)"
        }
    }
}
