
import ObjectMapper

class SaferizeSession: Mappable {
    
    enum Status: String {
        case ACTIVE
        case EXPIRED
    }
    
    var status: Status?
    var id: Int?
    var approval: Approval?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        status <- map["status"]
        approval <- map["approval"]
    }
    
    
    
}
