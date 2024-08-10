
import CEventLoop

public final class EventLoop {
	internal var handle: esp_event_loop_handle_t
	internal var handlers: [EventClosure] = []


	public init() {
		var handle = esp_event_loop_handle_t(bitPattern: 0)
		esp_event_loop_create(UnsafePointer<esp_event_loop_args_t>(bitPattern: 0), &handle)
		self.handle = handle!
	}

	deinit {
		esp_event_loop_delete(handle)
	}
	
	@discardableResult
	public func registerHandler(for event: (esp_event_base_t, Int32), handler: @escaping EventHandler) -> HandlerInstance {
		var instance = esp_event_handler_instance_t(bitPattern: 0)

		let closure = EventClosure(closure: handler)
		handlers.append(closure)

		esp_event_handler_instance_register_with(handle, event.0, event.1, { handler_arg, event_base, event_id, event_data in
			let closure = EventClosure.fromOpaque(handler_arg!)
			return closure.closure(event_base, event_id, event_data)	
		}, closure.toOpaque(), &instance)

		return HandlerInstance(handle: instance!)
	}

	@discardableResult
	public func registerHandler<Event: EventBase>(for event: Event, handler: @escaping EventHandler) -> HandlerInstance {
		registerHandler(for: (Event.identifier, event.rawValue), handler: handler)
	}

	@discardableResult
	public func registerHandler<Event: EventBase>(for event: Event.Type, handler: @escaping EventHandler) -> HandlerInstance {
		registerHandler(for: (Event.identifier, ESP_EVENT_ANY_ID), handler: handler)
	}

	public func unregisterHandler(for event: (esp_event_base_t, Int32), instance: HandlerInstance) {
		esp_event_handler_instance_unregister_with(handle, event.0, event.1, instance.handle)
	}

	public func unregisterHandler<Event: EventBase>(for event: Event, instance: HandlerInstance) {
		unregisterHandler(for: (Event.identifier, event.rawValue), instance: instance)
	}

	public func unregisterHandler<Event: EventBase>(for event: Event.Type, instance: HandlerInstance) {
		unregisterHandler(for: (Event.identifier, ESP_EVENT_ANY_ID), instance: instance)
	}
	
}
