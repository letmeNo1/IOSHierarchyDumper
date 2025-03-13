# IOSHierarchyDumper

本项目是一个基于 XCTest 和 GCDAsyncSocket 的 iOS 自动化测试服务器，它允许客户端通过 HTTP 请求与 iOS 设备进行交互，执行各种自动化测试任务，如应用激活、终止、元素查找、屏幕截图、录制等。

## 目录

- [安装](#安装)
- [使用](#使用)
- [贡献](#贡献)
- [许可证](#许可证)

## 安装

### 1. 克隆仓库

使用以下命令将仓库克隆到本地：

```bash
git clone https://github.com/letmeNo1/IOSHierarchyDumper.git
```

### 2. 打开项目

进入项目目录：

```bash
cd IOSHierarchyDumper
```

```bash
open dump_hierarchy.xcodeproj
```
或者，你也可以双击 project_name.xcodeproj 文件来打开项目


### 3. 配置签名设置
在Xcode中配置项目的签名设置：

在项目导航栏中选择项目。
进入 Signing & Capabilities 选项卡。
确保在 Signing 下选择了有效的团队。
![0cacb5abdb80a99ae0f489a726fd1a0](https://github.com/user-attachments/assets/bf93f97f-7dac-4cdd-a8b5-d9eed9be8907)

### 4. 编译并安装包

使用快捷键 Cmd + U 或通过 Product > Test

以下是根据你提供的代码生成的 README 文件：



## 功能特性
1. **网络通信**：使用 GCDAsyncSocket 监听指定端口，接收客户端的 HTTP 请求，并返回相应的结果。
2. **应用管理**：支持激活、终止指定的 iOS 应用。
3. **元素操作**：可以根据 XPath、索引、谓词等方式查找应用中的元素，并对元素执行点击、输入文本等操作。
4. **屏幕操作**：支持屏幕截图（PNG 和 JPG 格式）、屏幕录制功能。
5. **设备信息**：可以获取设备的屏幕尺寸、音频输出音量等信息。
6. **错误处理**：对各种异常情况进行了处理，如请求格式错误、参数缺失等，并返回相应的 HTTP 错误状态码。



### 启动服务器

运行 `MyServerTests` 类中的测试用例，服务器将在指定端口启动并开始监听客户端请求。

### 客户端请求示例

以下是一些常见的客户端请求示例：
1. **获取应用界面结构**
```
GET /dump_tree?bundle_id=com.example.app
```
2. **激活应用**
```
GET /activate_app?bundle_id=com.example.app
```
3. **终止应用**
```
GET /terminate_app?bundle_id=com.example.app
```
4. **开始屏幕录制**
```
GET /start_recording
```
5. **停止屏幕录制**
```
GET /stop_recording
```
6. **获取屏幕尺寸**
```
GET /get_actual_wh
```
7. **获取 PNG 格式的屏幕截图**
```
GET /get_png_pic
```
8. **获取 JPG 格式的屏幕截图**
```
GET /get_jpg_pic?compression_quality=0.8
```
9. **根据查询条件查找元素**
```
GET /find_elements_by_query?bundle_id=com.example.app&condition=label == 'Button'
```
10. **获取当前前台应用的 Bundle Identifier**
```
GET /get_current_bundleIdentifier?bundle_ids=com.example.app1,com.example.app2
```
11. **对元素执行操作**
```
GET /element_action?bundle_id=com.example.app&action=click&action_parms=&query_method=xpath&query_value=//Button[@name="Login"]
```
12. **根据坐标执行操作**
```
GET /coordinate_action?bundle_id=com.example.app&action=click&xPixel=100&yPixel=200&action_parms=
```
13. **执行设备操作**
```
GET /device_action?action=home
```
14. **获取设备信息**
```
GET /device_info?value=get_output_volume
```
15. **检查服务器状态**
```
GET /check_status
```

## 注意事项
1. **权限问题**：确保你的应用具有执行相应操作的权限，如屏幕截图、录制等。
2. **异常处理**：在使用过程中，可能会遇到各种异常情况，如网络连接失败、请求格式错误等，服务器会返回相应的 HTTP 错误状态码和错误信息。
3. **资源管理**：在长时间运行过程中，注意资源的释放和管理，避免内存泄漏等问题。

## 贡献与反馈
如果你发现了问题或有改进建议，请在项目的 GitHub 仓库中提交 Issue 或 Pull Request。我们欢迎任何形式的贡献！

## 许可证
本项目遵循 [MIT 许可证](https://opensource.org/licenses/MIT)，你可以自由使用、修改和分发本项目。


