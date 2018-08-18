

class SaferizeCallback {
    
    init() {
        
    }
    
    typealias  Event = ((SaferizeSession) -> Void)?
    
    var onConnect: Event
    var onDisconnect: Event
    var onPaused: Event
    var onResumed: Event
    var onTimeIsUp: Event
    var onError: Event
}
