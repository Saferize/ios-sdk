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

public class SaferizeService {

    
    private var session: SaferizeSession?
    private let ACCEPT_HEADER = "application/vnd.saferize.com+json;version=1"

    private var websocketCallback: SaferizeCallback!
    private var socket: WebSocket!
    
    private var websocketDelegate: Delegate!
    
    private var config: SaferizeConfig
    
    public init(config: SaferizeConfig ) {
        self.config = config
    }
    
    private func createJWT() -> String {
        var payload = JSONWebToken.Payload()
        payload.subject = config.accessKey
        payload.audience = ["https://saferize.com/principal"]
        payload.expiration = Date.init(timeIntervalSinceNow: 30)
        
        let key = try! RSAKey.keysFromPkcs12Identity(config.privateKey, passphrase: "")
        
        let signer = RSAPKCS1Signer(hashFunction: .sha256, key: key.privateKey)
        
        let jwt = try! JSONWebToken(payload: payload, signer: signer)
        return "Bearer " +  jwt.rawString
    }
    
    private func sendPost(path: String, data: [String: Any]?, callback:  ((String) -> Void)?) {
        
        let jwt = createJWT()
        
        let headers: HTTPHeaders = [
            "Authorization": jwt,
            "Accept": ACCEPT_HEADER
        ]
        Alamofire.request(config.url + path, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers ).responseString { response in
            debugPrint(response.result.value!)
            callback?(response.result.value!)
        }
    }
    
    public func signUp(parentEmail: String, userToken: String, callback: ((Approval?) -> Void)?)  {
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
    
    public func createSession(userToken: String, callback: ((SaferizeSession?) -> Void)?) {
        sendPost(path: "/session/app/" + userToken, data: nil, callback: {response in
            if let aSession = SaferizeSession(JSONString: response) {
                self.session = aSession
            }
            callback?(self.session)
        })
    }
    public func startWebSocketConnection(userToken: String, callback: SaferizeCallback) {
        
        let jwt = createJWT()
        
        var request = URLRequest(url: URL(string: config.websocketUrl + "?id=" + String(session!.id!))!)
        request.setValue(jwt, forHTTPHeaderField: "Authorization")
        request.setValue(ACCEPT_HEADER, forHTTPHeaderField: "Accept")
        
        socket = WebSocket(request: request)
        websocketDelegate = Delegate(websocketCallback: callback, session: self.session!)
        websocketCallback = callback;
        socket.delegate = websocketDelegate
        socket.respondToPingWithPong = true
        socket.connect()
    }
    

    
    
    class Delegate :WebSocketDelegate {
        
        private var websocketCallback: SaferizeCallback!
        private var session: SaferizeSession
        
        init(websocketCallback: SaferizeCallback, session: SaferizeSession) {
            self.websocketCallback = websocketCallback
            self.session = session
        }
        
        public func websocketDidConnect(socket: WebSocketClient) {
            websocketCallback.onConnect?(self.session)
        }
        
        public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
            websocketCallback.onDisconnect?(self.session)
            socket.connect()
        }
        
        public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
            let json = JSON(parseJSON: text)
            let eventType = json["eventType"];
            switch eventType {
            case "ApprovalStateChangedEvent":
                let approval = Approval(JSONString: json["entity"].rawString()!)
                if (Approval.State.PAUSED == approval?.currentState) {
                    websocketCallback.onPaused?(session)
                }
                if (Approval.State.ACTIVE == approval?.currentState) {
                    websocketCallback.onResumed?(session)
                }
                break;
            case "UsageTimerTimeIsUpEvent":
                websocketCallback.onTimeIsUp?(session)
                break;
            default:
                break;
            }
        }
        
        public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        }
    }
    

    
    
}
