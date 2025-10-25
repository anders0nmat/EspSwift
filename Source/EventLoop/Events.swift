
import CEventLoop

extension EventLoop {
	public protocol Event: RawRepresentable<Int32> {
		static var identifier: StaticString { get }
        static var eventBase: esp_event_base_t? { get }
	}

	public enum AnyEvent {
		public static let identifier: StaticString = ""
		static var eventBase: esp_event_base_t? { nil }
				
		public static var value: Int32 { ESP_EVENT_ANY_ID }
	}
}


extension EventLoop.Event {
	public static var eventBase: esp_event_base_t? {
        print("Read identifier eventBase")
		return UnsafeRawPointer(Self.identifier.utf8Start)
			.assumingMemoryBound(to: Int8.self)
	}
}

