//
//  SaferizeService.swift
//  ios-sdk
//
//  Created by rsteinberg on 16/08/2018.
//  Copyright © 2018 Saferize. All rights reserved.
//


import Alamofire
import KTVJSONWebToken
import Starscream
import SwiftyJSON

class SaferizeService:WebSocketDelegate {

    
    private var session: SaferizeSession?
    private let ACCEPT_HEADER = "application/vnd.saferize.com+json;version=1"

    private var websocketCallback: SaferizeCallback!
    private var socket: WebSocket!
    
    private func createJWT() -> String {
        var payload = JSONWebToken.Payload()
        payload.subject = "6b405c76-4b36-4821-9ab5-3a4a127b2af1"
        payload.audience = ["https://saferize.com/principal"]
        payload.expiration = Date.init(timeIntervalSinceNow: 30)
        
        let certificatePath = Bundle(for: SaferizeService.self).path(forResource: "saferize-dev", ofType: "p12")!
        
        let p12Data = try! Data(contentsOf: URL(fileURLWithPath: certificatePath))
        let key = try! RSAKey.keysFromPkcs12Identity(p12Data, passphrase: "")
        
        let signer = RSAPKCS1Signer(hashFunction: .sha256, key: key.privateKey)
        
        let jwt = try! JSONWebToken(payload: payload, signer: signer)
        return jwt.rawString
    }
    
    private func sendPost(path: String, data: [String: Any]?, callback:  ((String) -> Void)?) {
        
        let jwt = createJWT()
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + jwt,
            "Accept": ACCEPT_HEADER
        ]
        Alamofire.request("http://api.dev.saferize" + path, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers ).responseString { response in
            debugPrint(response.result.value!)
            callback?(response.result.value!)
        }
    }
    
    func signUp(parentEmail: String, userToken: String, callback: ((Approval?) -> Void)?)  {
        let root =  [
            "user": [
                "token": userToken
            ],
            "parent": [
                "email": parentEmail
            ]
        ]
        sendPost(path: "/approval",data: root, callback: {response in
            let approval = Approval(JSONString: response)
            callback?(approval)
        });
    }
    
    func createSession(userToken: String, callback: ((SaferizeSession?) -> Void)?) {
        sendPost(path: "/session/app/" + userToken, data: nil, callback: {response in
            if let aSession = SaferizeSession(JSONString: response) {
                self.session = aSession
            }
            callback?(self.session)
        })
    }
    func startWebSocketConnection(userToken: String, callback: SaferizeCallback) {
        
        let jwt = createJWT()
        
        var request = URLRequest(url: URL(string: "ws://websocket.dev.saferize/usage?id=" + String(session!.id!))!)
        request.setValue(jwt, forHTTPHeaderField: "Authentication")
        request.setValue(ACCEPT_HEADER, forHTTPHeaderField: "Accept")
        
        socket = WebSocket(request: request)
        websocketCallback = callback;
        socket.delegate = self
        socket.connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        websocketCallback.onConnect?(self.session!)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
         websocketCallback.onDisconnect?(self.session!)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let json = JSON(parseJSON: text)
        let eventType = json["eventType"];
        switch eventType {
        case "ApprovalStateChangedEvent":
            let approval = Approval(JSONString: json["entity"].rawString()!)
            if (Approval.State.PAUSED == approval?.currentState) {
                websocketCallback.onPaused?(session!)
            }
            if (Approval.State.ACTIVE == approval?.currentState) {
                websocketCallback.onResumed?(session!)
            }
            break;
        case "UsageTimerTimeIsUpEvent":
            websocketCallback.onTimeIsUp?(session!)
            break;
        default:
            break;
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    }
    

    

    
    
}
