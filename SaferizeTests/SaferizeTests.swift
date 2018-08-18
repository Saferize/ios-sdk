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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSignUp() {
        let service = SaferizeService()
        
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
        let service = SaferizeService()
        
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
        let service = SaferizeService()

        
        service.createSession(userToken: "MyToken", callback: { session in
            assert(session!.id! > 0)
            assert(session!.status == SaferizeSession.Status.ACTIVE)
            assert(session!.approval!.id! > 0)
            service.startWebSocketConnection(userToken: "MyToken", callback: callback)
        })

        
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    

    
}
