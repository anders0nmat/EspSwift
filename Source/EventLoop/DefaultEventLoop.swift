
import CEventLoop
import CClosures

public enum DefaultEventLoop {
	nonisolated(unsafe) internal static var handlers: [EventClosure] = []

	public static func create() {
		esp_event_loop_create_default()
	}

	public static func delete() {
		handlers = []
		esp_event_loop_delete_default()
	}

	@discardableResult
	public static func registerHandler(for event: (esp_event_base_t, Int32), handler: @escaping EventHandler) -> HandlerInstance {
		var instance = esp_event_handler_instance_t(bitPattern: 0)

		let closure = EventClosure(closure: handler)
		handlers.append(closure)

		esp_event_handler_instance_register(event.0, event.1, { handler_arg, event_base, event_id, event_data in
			let closure = EventClosure.fromOpaque(handler_arg!)
			return closure.closure(event_base, event_id, event_data)
		}, closure.toOpaque(), &instance)

		return HandlerInstance(handle: instance!)
	}

	public static func unregisterHandler(for event: (esp_event_base_t, Int32), instance: HandlerInstance) {
		esp_event_handler_instance_unregister(event.0, event.1, instance.handle)
	}

	@discardableResult
	public static func registerHandler<Event: EventBase>(for event: Event, handler: @escaping EventHandler) -> HandlerInstance {
		registerHandler(for: (Event.identifier, event.rawValue), handler: handler)
	}

	@discardableResult
	public static func registerHandler<Event: EventBase>(for event: Event.Type, handler: @escaping EventHandler) -> HandlerInstance {
		registerHandler(for: (Event.identifier, ESP_EVENT_ANY_ID), handler: handler)
	}

	public static func unregisterHandler<Event: EventBase>(for event: Event, instance: HandlerInstance) {
		unregisterHandler(for: (Event.identifier, event.rawValue), instance: instance)
	}

	public static func unregisterHandler<Event: EventBase>(for event: Event.Type, instance: HandlerInstance) {
		unregisterHandler(for: (Event.identifier, ESP_EVENT_ANY_ID), instance: instance)
	}
}
