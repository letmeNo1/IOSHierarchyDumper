import XCTest
import CocoaAsyncSocket

class MyServerTests: XCTestCase, GCDAsyncSocketDelegate {
    var listenSocket: GCDAsyncSocket!
    var connectedSockets = [GCDAsyncSocket]()

    override func setUp() {
        super.setUp()

        listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try listenSocket.accept(onPort: 0)
            print("Listening on port \(listenSocket.localPort)")
        } catch {
            print("Failed to listen on port: \(error)")
        }
    }

    override func tearDown() {
        super.tearDown()

        for socket in connectedSockets {
            socket.disconnect()
        }
        listenSocket.disconnect()
        listenSocket = nil
    }

    func testServer() {
        // 在这里，你可以发送请求到你的服务器，并检查服务器的响应。
        // 例如，你可以创建一个新的GCDAsyncSocket，连接到你的服务器，发送一个请求，然后检查服务器的响应。
    }

    // GCDAsyncSocketDelegate methods...

    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("Accepted new socket from \(newSocket.connectedHost ?? ""):\(newSocket.connectedPort)")
        connectedSockets.append(newSocket)
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if let message = String(data: data, encoding: .utf8) {
            print("Received message: \(message)")
        }
        sock.readData(withTimeout: -1, tag: 0)
    }

    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        sock.readData(withTimeout: -1, tag: 0)
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if let index = connectedSockets.firstIndex(of: sock) {
            connectedSockets.remove(at: index)
        }
    }
}
