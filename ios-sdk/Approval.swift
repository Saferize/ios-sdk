import ObjectMapper;

class Approval: Mappable {
   
    enum Status: String {
        case PENDING
        case NOTIFIED
        case APPROVED
        case REJECTED
    }
    
    enum State: String {
        case ACTIVE
        case PAUSED
    }
    
    var id: Int?
    var status: Status?
    var currentState: State?
    

    required init?(map: Map) {
        
    }

    
    func mapping(map: Map) {
        id <- map["id"]
        status <- map["status"]
        currentState <- map["currentState"]
    }
    

    
}
