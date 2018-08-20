import ObjectMapper;

public class Approval: Mappable {
   
    public enum Status: String {
        case PENDING
        case NOTIFIED
        case APPROVED
        case REJECTED
    }
    
    public enum State: String {
        case ACTIVE
        case PAUSED
    }
    
    public var id: Int?
    public var status: Status?
    public var currentState: State?
    

    public required init?(map: Map) {
        
    }

    
    public func mapping(map: Map) {
        id <- map["id"]
        status <- map["status"]
        currentState <- map["currentState"]
    }
    

    
}
