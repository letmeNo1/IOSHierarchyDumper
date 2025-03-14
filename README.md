# IOSHierarchyDumper{#ioshierarchydumper}

本项目是一个基于 XCTest 和 GCDAsyncSocket 的 iOS 自动化测试服务器，它允许客户端通过 HTTP 请求与 iOS 设备进行交互，执行各种自动化测试任务，如应用激活、终止、元素查找、屏幕截图、录制等。

## 目录{#目录}

- [安装](#安装)
  - [1. 克隆仓库](#1-克隆仓库)
  - [2. 打开项目](#2-打开项目)
  - [3. 配置签名设置](#3-配置签名设置)
  - [4. 编译并安装包](#4-编译并安装包)
  - [启动服务器](#启动服务器)
    - [安装 `py - ios`](#安装-py---ios)
    - [启动 XCTest](#启动-xctest)
    - [启动隧道（iOS 17+）](#启动隧道ios-17)
    - [启动端口转发](#启动端口转发)
- [功能特性](#功能特性)
- [使用](#使用)
  - [客户端请求示例](#客户端请求示例)
    - [1. 检查服务状态](#1-检查服务状态)
    - [2. 获取应用界面结构](#2-获取应用界面结构)
    - [3. 激活应用](#3-激活应用)
    - [4. 终止应用](#4-终止应用)
    - [5. 开始屏幕录制](#5-开始屏幕录制)
    - [6. 停止屏幕录制](#6-停止屏幕录制)
    - [7. 获取屏幕尺寸](#7-获取屏幕尺寸)
    - [8. 获取 PNG 格式的屏幕截图](#8-获取-png-格式的屏幕截图)
    - [9. 获取 JPG 格式的屏幕截图](#9-获取-jpg-格式的屏幕截图)
    - [10. 根据查询条件查找元素](#10-根据查询条件查找元素)
      - [`find_elements_by_query`](#find_elements_by_query)
      - [`find_element_by_query`](#find_element_by_query)
    - [11. 获取当前前台应用的 Bundle Identifier](#11-获取当前前台应用的-bundle-identifier)
    - [12. 根据坐标执行操作](#12-根据坐标执行操作)
    - [13. 执行设备操作](#13-执行设备操作)
    - [14. 获取设备信息](#14-获取设备信息)
- [注意事项](#注意事项)
- [贡献与反馈](#贡献与反馈)
- [许可证](#许可证)

## 安装{#安装}

### 1. 克隆仓库{#1-克隆仓库}
使用以下命令将仓库克隆到本地：
```bash
git clone https://github.com/letmeNo1/IOSHierarchyDumper.git
```

### 2. 打开项目{#2-打开项目}
进入项目目录：
```bash
cd IOSHierarchyDumper
```
使用以下命令打开项目：
```bash
open dump_hierarchy.xcodeproj
```
或者，你也可以直接在文件资源管理器中双击 `dump_hierarchy.xcodeproj` 文件来打开项目。

### 3. 配置签名设置{#3-配置签名设置}
在 Xcode 中配置项目的签名设置：
1. 在项目导航栏中选择项目。
2. 进入 `Signing & Capabilities` 选项卡。
3. 确保在 `Signing` 下选择了有效的团队。

![0cacb5abdb80a99ae0f489a726fd1a0](https://github.com/user-attachments/assets/bf93f97f-7dac-4cdd-a8b5-d9eed9be8907)

### 4. 编译并安装包{#4-编译并安装包}
使用快捷键 `Cmd + U` 或通过 `Product > Test` 来编译并运行测试。

### 启动服务器{#启动服务器}

#### 安装 `py - ios`{#安装-py---ios}
```bash
pip install py-ios
```

#### 启动 XCTest{#启动-xctest}
```bash
ios runwda --bundleid `nico.dump-hierarchyUITests.hank2.xctrunner` --testrunnerbundleid `nico.dump-hierarchyUITests.hank2.xctrunner` --xctestconfig=dump_hierarchyUITests.xctest --udid=00008140-001C7CD80202801C --env=USE_PORT=8200
```
请将 `nico.dump - hierarchyUITests.hank2.xctrunner` 替换为实际的包名，`USE_PORT` 为可选参数，默认端口为 8200。

#### 启动隧道（iOS 17+）{#启动隧道ios-17}
```bash
ios tunnel start
```

#### 启动端口转发{#启动端口转发}
```bash
ios forward 本地端口 远程端口
```

## 功能特性{#功能特性}
1. **网络通信**：使用 GCDAsyncSocket 监听指定端口，接收客户端的 HTTP 请求，并返回相应的结果。
2. **应用管理**：支持激活、终止指定的 iOS 应用。
3. **元素操作**：可以根据 XPath、索引、谓词等方式查找应用中的元素，并对元素执行点击、输入文本等操作。
4. **屏幕操作**：支持屏幕截图（PNG 和 JPG 格式）、屏幕录制功能。
5. **设备信息**：可以获取设备的屏幕尺寸、音频输出音量等信息。
6. **错误处理**：对各种异常情况进行了处理，如请求格式错误、参数缺失等，并返回相应的 HTTP 错误状态码。

## 使用{#使用}

### 客户端请求示例{#客户端请求示例}
以下是一些常见的客户端请求示例，假设服务器运行在 `http://localhost:8200` 上。

#### 1. 检查服务状态{#1-检查服务状态}
```plaintext
请求：
GET http://localhost:8200/check_status

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 13

server running
```
此请求用于检查服务器是否正常运行，若服务器正常，会返回 `server running`。

#### 2. 获取应用界面结构{#2-获取应用界面结构}
```plaintext
请求：
GET http://localhost:8200/dump_tree?bundle_id=com.example.app

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: ...

<应用界面结构的详细信息>
```
此请求用于获取指定 `bundle_id` 的应用的界面结构信息。

#### 3. 激活应用{#3-激活应用}
```plaintext
请求：
GET http://localhost:8200/activate_app?bundle_id=com.example.app

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 12

App activated
```
此请求用于激活指定 `bundle_id` 的应用。

#### 4. 终止应用{#4-终止应用}
```plaintext
请求：
GET http://localhost:8200/terminate_app?bundle_id=com.example.app

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 13

App terminated
```
此请求用于终止指定 `bundle_id` 的应用。

#### 5. 开始屏幕录制{#5-开始屏幕录制}
```plaintext
请求：
GET http://localhost:8200/start_recording

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 16

Recording started
```
此请求用于开始屏幕录制。

#### 6. 停止屏幕录制{#6-停止屏幕录制}
```plaintext
请求：
GET http://localhost:8200/stop_recording

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 16

Recording stopped
```
此请求用于停止屏幕录制。

#### 7. 获取屏幕尺寸{#7-获取屏幕尺寸}
```plaintext
请求：
GET http://localhost:8200/get_actual_wh

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: ...

<屏幕宽度>,<屏幕高度>
```
此请求用于获取设备屏幕的宽度和高度。

#### 8. 获取 PNG 格式的屏幕截图{#8-获取-png-格式的屏幕截图}
```plaintext
请求：
GET http://localhost:8200/get_png_pic

响应：
HTTP/1.1 200 OK
Content-Type: image/png
Content-Length: ...

<PNG 格式的屏幕截图二进制数据>
```
此请求用于获取设备屏幕的 PNG 格式截图。

#### 9. 获取 JPG 格式的屏幕截图{#9-获取-jpg-格式的屏幕截图}
```plaintext
请求：
GET http://localhost:8200/get_jpg_pic?compression_quality=0.8

响应：
HTTP/1.1 200 OK
Content-Type: image/jpeg
Content-Length: ...

<JPG 格式的屏幕截图二进制数据>
```
此请求用于获取设备屏幕的 JPG 格式截图，`compression_quality` 参数用于指定压缩质量。

#### 10. 根据查询条件查找元素{#10-根据查询条件查找元素}

##### `find_elements_by_query`{#find_elements_by_query}
此接口用于查找符合指定条件的所有元素。

```plaintext
请求：
GET http://localhost:8200/find_element_by_query?bundle_id=com.example.app&query_method=predicate&query_value=label == 'Button'

参数说明：
- bundle_id: 当前运行应用的 Bundle Identifier，例如 'com.example.app'(不要填错，否则会进入死循环)。
- query_method: 查询方法 仅支持 'predicate'
- query_value:  'label == 'Button'' 表示查找标签为 'Button' 的元素。

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: ...

<符合条件的元素信息，以逗号分隔>

示例响应：
<element1_json_info>,<element2_json_info>,<element3_json_info>
```

##### `find_element_by_query`{#find_element_by_query}
此接口用于查找符合指定条件的第一个元素。

```plaintext
请求：
GET http://localhost:8200/find_element_by_query?bundle_id=com.example.app&query_method=predicate&query_value=label == 'Button'

参数说明：
- bundle_id: 当前运行应用的 Bundle Identifier，例如 'com.example.app'(不要填错，否则会进入死循环)。
- query_method: 查询方法，支持 'xpath'、'index'、'predicate' 等。这里使用 'predicate' 表示使用谓词查询。
- query_value: 查询值，根据查询方法的不同而不同。当查询方法为 'predicate' 时，这里的 'label == 'Button'' 表示查找标签为 'Button' 的元素。

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: ...

<符合条件的第一个元素的 JSON 信息>

示例响应：
<element1_json_info>
```

#### 11. 获取当前前台应用的 Bundle Identifier{#11-获取当前前台应用的-bundle-identifier}
```plaintext
请求：
GET http://localhost:8200/get_current_bundleIdentifier?bundle_ids=com.example.app1,com.example.app2

参数说明：
- bundle_ids: 当前手机上所有安装的应用包名

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: ...

<当前前台应用的 Bundle Identifier>
```
此请求用于获取当前前台运行的应用的 `Bundle Identifier`。

#### 12. 根据坐标执行操作{#12-根据坐标执行操作}
```plaintext
请求：
GET http://localhost:8200/coordinate_action?bundle_id=com.example.app&action=click&xPixel=100&yPixel=200&action_parms=

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 22

Coordinate action performed
```
此请求用于在指定应用的指定坐标处执行操作。

#### 13. 执行设备操作{#13-执行设备操作}
```plaintext
请求：
GET http://localhost:8200/device_action?action=home

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 20

Device action performed
```
此请求用于执行设备的物理操作，如按下 `Home` 键。

#### 14. 获取设备信息{#14-获取设备信息}
```plaintext
请求：
GET http://localhost:8200/device_info?value=get_output_volume

响应：
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: ...

<设备的音频输出音量信息>
```
此请求用于获取设备的相关信息，如音频输出音量。

## 注意事项{#注意事项}
1. **权限问题**：确保你的应用具有执行相应操作的权限，如屏幕截图、录制等。
2. **异常处理**：在使用过程中，可能会遇到各种异常情况，如网络连接失败、请求格式错误等，服务器会返回相应的 HTTP 错误状态码和错误信息。
3. **资源管理**：在长时间运行过程中，注意资源的释放和管理，避免内存泄漏等问题。

## 贡献与反馈{#贡献与反馈}
如果你发现了问题或有改进建议，请在项目的 GitHub 仓库中提交 Issue 或 Pull Request。我们欢迎任何形式的贡献！

## 许可证{#许可证}
本项目遵循 [MIT 许可证](https://opensource.org/licenses/MIT)，你可以自由使用、修改和分发本项目。


# IOSHierarchyDumper{#ioshierarchydumper-1}

This project is an iOS automated testing server based on XCTest and GCDAsyncSocket, allowing clients to interact with iOS devices via HTTP requests for various automated testing tasks such as app activation, termination, element lookup, screenshots, screen recording, etc.

## Table of Contents{#table-of-contents}

- [Installation](#installation)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Open the Project](#2-open-the-project)
  - [3. Configure Signing Settings](#3-configure-signing-settings)
  - [4. Compile and Install](#4-compile-and-install)
  - [Start the Server](#start-the-server)
    - [Install `py-ios`](#install-py-ios)
    - [Launch XCTest](#launch-xctest)
    - [Start Tunnel (iOS 17+)](#start-tunnel-ios-17)
    - [Port Forwarding](#port-forwarding)
- [Features](#features)
- [Usage](#usage)
  - [Client Request Examples](#client-request-examples)
    - [1. Check Server Status](#1-check-server-status)
    - [2. Get App UI Hierarchy](#2-get-app-ui-hierarchy)
    - [3. Activate App](#3-activate-app)
    - [4. Terminate App](#4-terminate-app)
    - [5. Start Screen Recording](#5-start-screen-recording)
    - [6. Stop Screen Recording](#6-stop-screen-recording)
    - [7. Get Screen Dimensions](#7-get-screen-dimensions)
    - [8. Get PNG Screenshot](#8-get-png-screenshot)
    - [9. Get JPG Screenshot](#9-get-jpg-screenshot)
    - [10. Find Elements by Query](#10-find-elements-by-query)
      - [`find_elements_by_query`](#find_elements_by_query-1)
      - [`find_element_by_query`](#find_element_by_query-1)
    - [11. Get Foreground App Bundle ID](#11-get-foreground-app-bundle-id)
    - [12. Coordinate-Based Actions](#12-coordinate-based-actions)
    - [13. Device Actions](#13-device-actions)
    - [14. Get Device Info](#14-get-device-info)
- [Notes](#notes)
- [Contribution & Feedback](#contribution--feedback)
- [License](#license)

## Installation{#installation}

### 1. Clone the Repository{#1-clone-the-repository}
Use the following command to clone the repository locally:
```bash
git clone https://github.com/letmeNo1/IOSHierarchyDumper.git
```

### 2. Open the Project{#2-open-the-project}
Navigate to the project directory:
```bash
cd IOSHierarchyDumper
```
Open the project using:
```bash
open dump_hierarchy.xcodeproj
```
Alternatively, double-click `dump_hierarchy.xcodeproj` in the file explorer.

### 3. Configure Signing Settings{#3-configure-signing-settings}
In Xcode:
1. Select the project in the navigator.
2. Go to the `Signing & Capabilities` tab.
3. Ensure a valid team is selected under `Signing`.

![0cacb5abdb80a99ae0f489a726fd1
