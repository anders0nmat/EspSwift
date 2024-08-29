
import CEspWiFi
import FreeRTOS
import EventLoop

public enum WiFi {
	nonisolated(unsafe) private static var instance: WiFiInstance?
}

extension WiFi {
	public static func start(mode: WiFiMode) {
		guard instance == nil else { return }

		instance = WiFiInstance(mode: mode)

		nvs_flash_init()

		esp_netif_init()

		DefaultEventLoop.create()

		switch mode {
		case .station:
			instance!.netifSTAHandle = esp_netif_create_default_wifi_sta()
		case .accessPoint:
			instance!.netifAPHandle = esp_netif_create_default_wifi_ap()
		case .accessPointStation:
			instance!.netifAPHandle = esp_netif_create_default_wifi_ap()
			instance!.netifSTAHandle = esp_netif_create_default_wifi_sta()
		}

		var config = esp_wifi_config_default()
		esp_wifi_init(&config)

		DefaultEventLoop.registerHandler(for: WiFiEvent.self) {
			WiFi.instance?.event_handler(event_base: $0, event_id: $1, event_data: $2)
		}

		DefaultEventLoop.registerHandler(for: (IP_EVENT, Int32(IP_EVENT_STA_GOT_IP.rawValue))) {
			WiFi.instance?.event_handler(event_base: $0, event_id: $1, event_data: $2)
		}
	}

	public static func connect(
	to ssid: String,
	password: String,
	securityLevel: WiFiSecurity = .WPA2_WPA3) {
		start(mode: .station)
		guard instance!.mode.isStation else { return }
		
		var config = wifi_config_t()
		esp_wifi_copy_static_string(&config.sta.ssid, ssid, 32)
		esp_wifi_copy_static_string(&config.sta.password, password, 64)

		config.sta.threshold.authmode = securityLevel.value

		print("Starting WiFi Station...")

		esp_wifi_set_mode(WIFI_MODE_STA)
		esp_wifi_set_config(WIFI_IF_STA, &config)
		esp_wifi_start()

		if let eventBits = instance!.eventGroup.wait(for: [.connected, .failed], .any, timeout: .maximum) {
			if eventBits.contains(.connected) {
				print("connected to ap")
			}
			else if eventBits.contains(.failed) {
				print("connection to ap failed")
			}
		}
		else {
			print("unexpected event")
		}
	}
}

extension WiFi {
	public enum WiFiMode {
		case station
		case accessPoint
		case accessPointStation

		internal var isStation: Bool {
			return switch self {
				case .station, .accessPointStation: true
				case .accessPoint: false
			}
		}

		internal var isAccessPoint: Bool {
			return switch self {
				case .station: false
				case .accessPoint, .accessPointStation: true
			}
		}
	}

	public enum WiFiSecurity {
		case open
		case WEP
		case WPA
		case WPA2
		case WPA3
		case WPA_WPA2
		case WPA2_WPA3

		internal var value: wifi_auth_mode_t {
			return switch self {
			case .open: WIFI_AUTH_OPEN
			case .WEP: WIFI_AUTH_WEP
			case .WPA: WIFI_AUTH_WPA_PSK
			case .WPA2: WIFI_AUTH_WPA2_PSK
			case .WPA3: WIFI_AUTH_WPA3_PSK
			case .WPA_WPA2: WIFI_AUTH_WPA_WPA2_PSK
			case .WPA2_WPA3: WIFI_AUTH_WPA2_WPA3_PSK
			}
		}
	}

	private struct WiFiInstance {
		var mode: WiFiMode

		var netifAPHandle: OpaquePointer?
		var netifSTAHandle: OpaquePointer?

		struct EventFlag: BitSet {
			let rawValue: RawValue

			static let connected = Self(bit: 0)
			static let failed    = Self(bit: 1)
		}

		var eventGroup = EventGroup<EventFlag>()

		var connection_tries = 0
		mutating func event_handler(event_base: esp_event_base_t?, event_id: Int32, event_data: UnsafeMutableRawPointer?) {
			if event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START.rawValue {
				print("First connection attempt...")
				esp_wifi_connect()
			}
			else if event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED.rawValue {
				if connection_tries < 10 {
					print("Trying to (re)connect...")
					esp_wifi_connect()
					connection_tries += 1
				}
				else {
					eventGroup.set(.failed)
				}				
			}
			else if event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP.rawValue {
				let ip_event = event_data!.assumingMemoryBound(to: ip_event_got_ip_t.self)
				let ip = ip_event.pointee.ip_info.ip
				print("got ip: \((ip.addr >> 0) & 0xFF).\((ip.addr >> 8) & 0xFF).\((ip.addr >> 16) & 0xFF).\((ip.addr >> 24) & 0xFF)")
				connection_tries = 0
				eventGroup.set(.connected)
			}
		}
	}
}


