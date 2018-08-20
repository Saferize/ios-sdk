import Foundation

public class SaferizeConfig {
    public var url: String
    public var websocketUrl: String
    public var accessKey: String
    public var privateKey: Data
    
    public init(url: String, websocketUrl: String, accessKey: String, privateKey: Data) {
        self.url = url
        self.websocketUrl = websocketUrl
        self.accessKey = accessKey
        self.privateKey = privateKey
    }
}
