//
//  TestWebsocket.swift
//  SaferizeTests
//
//  Created by rsteinberg on 8/17/18.
//  Copyright © 2018 Saferize. All rights reserved.
//

import XCTest
import Starscream

class TestWebsocket: XCTestCase, WebSocketDelegate {
    
     var socket: WebSocket!
    var e: XCTestExpectation!
    
    
    func websocketDidConnect(socket: WebSocketClient) {
            print("websocket is connected")
        e.fulfill()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        e = expectation(description: "Approval")
        self.socket = WebSocket(url: URL(string: "wss://echo.websocket.org")!)
        self.socket.delegate = self
        print("TRYING TO CONNECT")
        self.socket.connect()
        print("DONE TRYING")
        waitForExpectations(timeout: 15.0, handler: nil)
    }
    

    
}
