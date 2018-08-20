
import ObjectMapper

public class SaferizeSession: Mappable {
    
    public enum Status: String {
        case ACTIVE
        case EXPIRED
    }
    
    public var status: Status?
    public var id: Int?
    public var approval: Approval?
    
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        status <- map["status"]
        approval <- map["approval"]
    }
    
    
    
}
