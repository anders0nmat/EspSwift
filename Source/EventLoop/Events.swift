
import CEventLoop

public protocol EventBase {
	static var identifier: esp_event_base_t { get }
	var rawValue: Int32 { get }
}

public enum AnyEventBase: EventBase {
	public var rawValue: Int32 { ESP_EVENT_ANY_ID }

    public static var identifier: esp_event_base_t { esp_event_base_t(bitPattern: 0)! }
}

