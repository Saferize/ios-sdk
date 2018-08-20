//
//  SaferizeTests.swift
//  SaferizeTests
//
//  Created by rsteinberg on 8/16/18.
//  Copyright © 2018 Saferize. All rights reserved.
//

import XCTest
@testable import ios_sdk


class SaferizeTests: XCTestCase {
    
    var config: SaferizeConfig!
    
    override func setUp() {
        super.setUp()
        
        let certificatePath = Bundle(for: SaferizeService.self).path(forResource: "saferize-dev", ofType: "p12")!
        
        let p12Data = try! Data(contentsOf: URL(fileURLWithPath: certificatePath))

        config = SaferizeConfig(url: "http://api.dev.saferize", websocketUrl: "ws://websocket.dev.saferize/usage", accessKey: "6b405c76-4b36-4821-9ab5-3a4a127b2af1", privateKey: p12Data)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSignUp() {
        
        let service = SaferizeService(config: config)
        
        let e = expectation(description: "Approval")
        
        service.signUp(parentEmail: "renato@saferize.com", userToken: "MyToken", callback: { approval in
            assert(approval!.id! > 0)
            assert(approval!.status == Approval.Status.PENDING)
            assert(approval!.currentState == Approval.State.ACTIVE)
                e.fulfill()
        })
        
        waitForExpectations(timeout: 40.0, handler: nil)
    }
    
    func testCreateSession() {
        let service = SaferizeService(config: config)
        
        let e = expectation(description: "Approval")
        
        service.createSession(userToken: "MyToken", callback: { session in
            assert(session!.id! > 0)
            assert(session!.status == SaferizeSession.Status.ACTIVE)
            assert(session!.approval!.id! > 0)
            e.fulfill()
        })
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    
    
    func testWebSocket() {
        
        let e = expectation(description: "Connected")

        let callback = SaferizeCallback()
        
        callback.onConnect = { session in
            e.fulfill()
        }
        let service = SaferizeService(config: config)

        
        service.createSession(userToken: "MyToken", callback: { session in
            assert(session!.id! > 0)
            assert(session!.status == SaferizeSession.Status.ACTIVE)
            assert(session!.approval!.id! > 0)
            service.startWebSocketConnection(userToken: "MyToken", callback: callback)
        })

        
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    

    
}
