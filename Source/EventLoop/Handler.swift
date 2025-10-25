
import CClosures
import CEventLoop

public typealias EventHandler = (esp_event_base_t?, Int32, UnsafeMutableRawPointer?) -> Void
internal typealias EventClosure = Closure<EventHandler>

public struct HandlerInstance {
	internal var handle = esp_event_handler_instance_t(bitPattern: 0)
	internal var closure: EventClosure
}

extension HandlerInstance: Equatable {
	public static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.closure === rhs.closure && lhs.handle == rhs.handle
	}
}
