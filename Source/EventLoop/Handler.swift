
import CClosures
import CEventLoop

public typealias EventHandler = (esp_event_base_t?, Int32, UnsafeMutableRawPointer?) -> Void
public typealias EventClosure = Closure<EventHandler>

public struct HandlerInstance {
	internal let handle: esp_event_handler_instance_t

	internal init(handle: esp_event_handler_instance_t) {
		self.handle = handle
	}
}
