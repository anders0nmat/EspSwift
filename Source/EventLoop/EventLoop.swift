
import CEventLoop
import FreeRTOS

public protocol AnyEventLoop {
	func register(for event: (esp_event_base_t?, Int32), handler: @escaping EventHandler) -> HandlerInstance
	func unregister(for event: (esp_event_base_t?, Int32), instance: HandlerInstance)
	func post(_ event: (esp_event_base_t?, Int32), data: UnsafeRawPointer?, size: Int, timeout: RTOSClock.Duration)
}

private func handleEvent(handler_arg: UnsafeMutableRawPointer?, event_base: esp_event_base_t?, event_id: Int32, event_data: UnsafeMutableRawPointer?) {
    let closure = EventClosure.fromOpaque(handler_arg!)
	closure.closure(event_base, event_id, event_data)
}

public class DefaultEventLoop: AnyEventLoop {
	internal var handlers: [HandlerInstance] = []

	internal init() { create() }
	public func create() { esp_event_loop_create_default() }
	public func delete() { esp_event_loop_delete_default() }

	@discardableResult
	public func register(for event: (esp_event_base_t?, Int32), handler: @escaping EventHandler) -> HandlerInstance {
		var instance = HandlerInstance(closure: .init(closure: handler))
		esp_event_handler_instance_register(event.0, event.1, handleEvent, instance.closure.toOpaque(), &instance.handle)
		handlers.append(instance)
		return instance
	}

	public func unregister(for event: (esp_event_base_t?, Int32), instance: HandlerInstance) {
		esp_event_handler_instance_unregister(event.0, event.1, instance.handle)
		handlers.removeAll { $0 == instance }
	}

	public func post(_ event: (esp_event_base_t?, Int32), data: UnsafeRawPointer?, size: Int, timeout: RTOSClock.Duration) {
		esp_event_post(event.0, event.1, data, size, timeout.ticks)
	}
}

public class EventLoop: AnyEventLoop {
	public nonisolated(unsafe) static let `default` = DefaultEventLoop()

	public internal(set) var handle = esp_event_loop_handle_t(bitPattern: 0)
	internal var handlers: [HandlerInstance] = []

	public init() {
		esp_event_loop_create(.init(bitPattern: 0), &handle)
	}

	deinit {
		esp_event_loop_delete(handle)
	}

	@discardableResult
	public func register(for event: (esp_event_base_t?, Int32), handler: @escaping EventHandler) -> HandlerInstance {
		var instance = HandlerInstance(closure: .init(closure: handler))
		esp_event_handler_instance_register_with(handle, event.0, event.1, handleEvent, instance.closure.toOpaque(), &instance.handle)
		handlers.append(instance)
		return instance
	}

	public func unregister(for event: (esp_event_base_t?, Int32), instance: HandlerInstance) {
		esp_event_handler_instance_unregister_with(handle, event.0, event.1, instance.handle)
		handlers.removeAll { $0 == instance }
	}

	public func post(_ event: (esp_event_base_t?, Int32), data: UnsafeRawPointer?, size: Int, timeout: RTOSClock.Duration) {
		esp_event_post_to(handle, event.0, event.1, data, size, timeout.ticks)
	}
}

extension AnyEventLoop {
	@discardableResult
	public func register<Event: EventLoop.Event>(for event: Event, handler: @escaping EventHandler) -> HandlerInstance {
		register(for: (Event.eventBase, event.rawValue), handler: handler)
	}
	public func unregister<Event: EventLoop.Event>(for event: Event, instance: HandlerInstance) {
		unregister(for: (Event.eventBase, event.rawValue), instance: instance)
	}

	@discardableResult
	public func register<Event: EventLoop.Event>(for event: Event.Type, handler: @escaping EventHandler) -> HandlerInstance {
		register(for: (Event.eventBase, EventLoop.AnyEvent.value), handler: handler)
	}
	public func unregister<Event: EventLoop.Event>(for event: Event.Type, instance: HandlerInstance) {
		unregister(for: (Event.eventBase, EventLoop.AnyEvent.value), instance: instance)
	}

	@discardableResult
	public func register(for event: EventLoop.AnyEvent.Type, handler: @escaping EventHandler) -> HandlerInstance {
		register(for: (EventLoop.AnyEvent.eventBase, EventLoop.AnyEvent.value), handler: handler)
	}

	@discardableResult
	public func register<Event: EventLoop.Event>(for event: Event.Type, handler: @escaping (Event, UnsafeMutableRawPointer?) -> Void) -> HandlerInstance {
		register(for: Event.self) { eventBase, eventId, data in
			if let event = Event(rawValue: eventId), eventBase == Event.eventBase {
				handler(event, data)
			}
		}
	}

	public func post<Event: EventLoop.Event, T>(_ event: Event, data: inout T, timeout: RTOSClock.Duration) {
		withUnsafeBytes(of: &data) {
			post((Event.eventBase, event.rawValue), data: $0.baseAddress, size: $0.count, timeout: timeout)
		}
	}
}
