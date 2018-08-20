//
//  ViewController.swift
//  ExampleApp
//
//  Created by rsteinberg on 8/17/18.
//  Copyright © 2018 Saferize. All rights reserved.
//

import UIKit
import ios_sdk


class ViewController: UIViewController {

    @IBOutlet weak var parentTextField: UITextField!

    private var saferizeService: SaferizeService!
    private var userToken = "MyUserToken_" + String(Date().timeIntervalSince1970)
    private var saferizeCallback: SaferizeCallback!
   
    private var config: SaferizeConfig!
    
    @IBOutlet weak var logTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let certificatePath = Bundle(for: SaferizeService.self).path(forResource: "saferize-dev", ofType: "p12")!
        
        let p12Data = try! Data(contentsOf: URL(fileURLWithPath: certificatePath))
        
        config = SaferizeConfig(url: "http://api.dev.saferize", websocketUrl: "ws://websocket.dev.saferize/usage", accessKey: "6b405c76-4b36-4821-9ab5-3a4a127b2af1", privateKey: p12Data)
        
        saferizeService = SaferizeService(config: config);
        // Do any additional setup after loading the view, typically from a nib.
        saferizeCallback = SaferizeCallback()
        saferizeCallback.onConnect = self.onConnect
        saferizeCallback.onDisconnect = self.onDisconnect
        saferizeCallback.onError = self.onError
        saferizeCallback.onPaused = self.onPaused
        saferizeCallback.onResumed = self.onResumed
        saferizeCallback.onTimeIsUp = self.onTimeIsUp
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func printLog(_ text: String) {
        logTextView.text = logTextView.text + "\n" + text
    }
    
    private func onConnect(session: SaferizeSession) {
        self.printLog("Websocket Connected: " + String(session.id!))
    }
    
    private func onDisconnect(session: SaferizeSession) {
        self.printLog("Websocket Disconnected: " + String(session.id!))
    }
    
    
    private func onError(session: SaferizeSession) {
        self.printLog("Webscoket Error: " + String(session.id!))
    }
    
    private func onPaused(session: SaferizeSession) {
        self.printLog("Websocket Paused: " + String(session.id!))
    }
    
    private func onResumed(session: SaferizeSession) {
        self.printLog("Websocket Resumed: " + String(session.id!))
    }
    
    private func onTimeIsUp(session: SaferizeSession) {
        self.printLog("Websocket TimeIsUp: " + String(session.id!))
    }

    @IBAction func signUpClicked(_ sender: UIButton) {
        debugPrint("SignUp Clicked " + parentTextField.text!)
        printLog("SignUp Clicked " + parentTextField.text!)
        saferizeService.signUp(parentEmail: parentTextField.text!, userToken: userToken) { (approval) in
            self.printLog("Signed Up: Approval Id:" + String(approval!.id!))
            self.saferizeService.createSession(userToken: self.userToken, callback: { (session) in
                self.printLog("Created Session: " + String(session!.id!))
                self.saferizeService.startWebSocketConnection(userToken: self.userToken, callback: self.saferizeCallback)
            })
        }
    }
    
}

