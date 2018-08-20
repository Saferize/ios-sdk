

public class SaferizeCallback {
    
    public init() {
        
    }
    
    public typealias  Event = ((SaferizeSession) -> Void)?
    
    public var onConnect: Event
    public var onDisconnect: Event
    public var onPaused: Event
    public var onResumed: Event
    public var onTimeIsUp: Event
    public var onError: Event
}
