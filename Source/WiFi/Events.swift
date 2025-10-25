
import EventLoop
import CEspWiFi

public enum WiFiEvent: EventLoop.Event {
	public static var identifier: StaticString { "WIFI_EVENT" }
    public static var eventBase: esp_event_base_t? { WIFI_EVENT }

	case wifiReady
	case scanDone

	case staStart
	case staStop
	case staConnected
	case staDisconnected
	case staAuthmodeChange
	case staWpsErSuccess
	case staWpsErFailed
	case staWpsErTimeout
	case staWpsErPin
	case staWpsErPbcOverlap
	case staBssRssiLow
	case staBeaconTimeout
	
	case apStart
	case apStop
	case apStaconnected
	case apStadisconnected
	case apProbereqrecved
	case apWpsRgSuccess
	case apWpsRgFailed
	case apWpsRgTimeout
	case apWpsRgPin
	case apWpsRgPbcOverlap
	
	case nanStarted
	case nanStopped
	case nanSvcMatch
	case nanReplied
	case nanReceive
	
	case ftmReport
	
	case actionTxStatus
	case rocDone
	case connectionlessModuleWakeIntervalStart
	case itwtSetup
	case itwtTeardown
	case itwtProbe
	case itwtSuspend
	case twtWakeup
	case ndpIndication
	case ndpConfirm
	case ndpTerminated
	case homeChannelChange

	public var rawValue: Int32 {
		return switch self {
		case .wifiReady: Int32(WIFI_EVENT_WIFI_READY.rawValue)
		case .scanDone: Int32(WIFI_EVENT_SCAN_DONE.rawValue)
		case .staStart: Int32(WIFI_EVENT_STA_START.rawValue)
		case .staStop: Int32(WIFI_EVENT_STA_STOP.rawValue)
		case .staConnected: Int32(WIFI_EVENT_STA_CONNECTED.rawValue)
		case .staDisconnected: Int32(WIFI_EVENT_STA_DISCONNECTED.rawValue)
		case .staAuthmodeChange: Int32(WIFI_EVENT_STA_AUTHMODE_CHANGE.rawValue)
		case .staWpsErSuccess: Int32(WIFI_EVENT_STA_WPS_ER_SUCCESS.rawValue)
		case .staWpsErFailed: Int32(WIFI_EVENT_STA_WPS_ER_FAILED.rawValue)
		case .staWpsErTimeout: Int32(WIFI_EVENT_STA_WPS_ER_TIMEOUT.rawValue)
		case .staWpsErPin: Int32(WIFI_EVENT_STA_WPS_ER_PIN.rawValue)
		case .staWpsErPbcOverlap: Int32(WIFI_EVENT_STA_WPS_ER_PBC_OVERLAP.rawValue)
		case .apStart: Int32(WIFI_EVENT_AP_START.rawValue)
		case .apStop: Int32(WIFI_EVENT_AP_STOP.rawValue)
		case .apStaconnected: Int32(WIFI_EVENT_AP_STACONNECTED.rawValue)
		case .apStadisconnected: Int32(WIFI_EVENT_AP_STADISCONNECTED.rawValue)
		case .apProbereqrecved: Int32(WIFI_EVENT_AP_PROBEREQRECVED.rawValue)
		case .ftmReport: Int32(WIFI_EVENT_FTM_REPORT.rawValue)
		case .staBssRssiLow: Int32(WIFI_EVENT_STA_BSS_RSSI_LOW.rawValue)
		case .actionTxStatus: Int32(WIFI_EVENT_ACTION_TX_STATUS.rawValue)
		case .rocDone: Int32(WIFI_EVENT_ROC_DONE.rawValue)
		case .staBeaconTimeout: Int32(WIFI_EVENT_STA_BEACON_TIMEOUT.rawValue)
		case .connectionlessModuleWakeIntervalStart: Int32(WIFI_EVENT_CONNECTIONLESS_MODULE_WAKE_INTERVAL_START.rawValue)
		case .apWpsRgSuccess: Int32(WIFI_EVENT_AP_WPS_RG_SUCCESS.rawValue)
		case .apWpsRgFailed: Int32(WIFI_EVENT_AP_WPS_RG_FAILED.rawValue)
		case .apWpsRgTimeout: Int32(WIFI_EVENT_AP_WPS_RG_TIMEOUT.rawValue)
		case .apWpsRgPin: Int32(WIFI_EVENT_AP_WPS_RG_PIN.rawValue)
		case .apWpsRgPbcOverlap: Int32(WIFI_EVENT_AP_WPS_RG_PBC_OVERLAP.rawValue)
		case .itwtSetup: Int32(WIFI_EVENT_ITWT_SETUP.rawValue)
		case .itwtTeardown: Int32(WIFI_EVENT_ITWT_TEARDOWN.rawValue)
		case .itwtProbe: Int32(WIFI_EVENT_ITWT_PROBE.rawValue)
		case .itwtSuspend: Int32(WIFI_EVENT_ITWT_SUSPEND.rawValue)
		case .twtWakeup: Int32(WIFI_EVENT_TWT_WAKEUP.rawValue)
		case .nanStarted: Int32(WIFI_EVENT_NAN_STARTED.rawValue)
		case .nanStopped: Int32(WIFI_EVENT_NAN_STOPPED.rawValue)
		case .nanSvcMatch: Int32(WIFI_EVENT_NAN_SVC_MATCH.rawValue)
		case .nanReplied: Int32(WIFI_EVENT_NAN_REPLIED.rawValue)
		case .nanReceive: Int32(WIFI_EVENT_NAN_RECEIVE.rawValue)
		case .ndpIndication: Int32(WIFI_EVENT_NDP_INDICATION.rawValue)
		case .ndpConfirm: Int32(WIFI_EVENT_NDP_CONFIRM.rawValue)
		case .ndpTerminated: Int32(WIFI_EVENT_NDP_TERMINATED.rawValue)
		case .homeChannelChange: Int32(WIFI_EVENT_HOME_CHANNEL_CHANGE.rawValue)
		}
	}

	public init?(rawValue: Int32) {
		switch UInt32(rawValue) {
			case WIFI_EVENT_WIFI_READY.rawValue: self = .wifiReady
			case WIFI_EVENT_SCAN_DONE.rawValue: self = .scanDone
			case WIFI_EVENT_STA_START.rawValue: self = .staStart
			case WIFI_EVENT_STA_STOP.rawValue: self = .staStop
			case WIFI_EVENT_STA_CONNECTED.rawValue: self = .staConnected
			case WIFI_EVENT_STA_DISCONNECTED.rawValue: self = .staDisconnected
			case WIFI_EVENT_STA_AUTHMODE_CHANGE.rawValue: self = .staAuthmodeChange
			case WIFI_EVENT_STA_WPS_ER_SUCCESS.rawValue: self = .staWpsErSuccess
			case WIFI_EVENT_STA_WPS_ER_FAILED.rawValue: self = .staWpsErFailed
			case WIFI_EVENT_STA_WPS_ER_TIMEOUT.rawValue: self = .staWpsErTimeout
			case WIFI_EVENT_STA_WPS_ER_PIN.rawValue: self = .staWpsErPin
			case WIFI_EVENT_STA_WPS_ER_PBC_OVERLAP.rawValue: self = .staWpsErPbcOverlap
			case WIFI_EVENT_AP_START.rawValue: self = .apStart
			case WIFI_EVENT_AP_STOP.rawValue: self = .apStop
			case WIFI_EVENT_AP_STACONNECTED.rawValue: self = .apStaconnected
			case WIFI_EVENT_AP_STADISCONNECTED.rawValue: self = .apStadisconnected
			case WIFI_EVENT_AP_PROBEREQRECVED.rawValue: self = .apProbereqrecved
			case WIFI_EVENT_FTM_REPORT.rawValue: self = .ftmReport
			case WIFI_EVENT_STA_BSS_RSSI_LOW.rawValue: self = .staBssRssiLow
			case WIFI_EVENT_ACTION_TX_STATUS.rawValue: self = .actionTxStatus
			case WIFI_EVENT_ROC_DONE.rawValue: self = .rocDone
			case WIFI_EVENT_STA_BEACON_TIMEOUT.rawValue: self = .staBeaconTimeout
			case WIFI_EVENT_CONNECTIONLESS_MODULE_WAKE_INTERVAL_START.rawValue: self = .connectionlessModuleWakeIntervalStart
			case WIFI_EVENT_AP_WPS_RG_SUCCESS.rawValue: self = .apWpsRgSuccess
			case WIFI_EVENT_AP_WPS_RG_FAILED.rawValue: self = .apWpsRgFailed
			case WIFI_EVENT_AP_WPS_RG_TIMEOUT.rawValue: self = .apWpsRgTimeout
			case WIFI_EVENT_AP_WPS_RG_PIN.rawValue: self = .apWpsRgPin
			case WIFI_EVENT_AP_WPS_RG_PBC_OVERLAP.rawValue: self = .apWpsRgPbcOverlap
			case WIFI_EVENT_ITWT_SETUP.rawValue: self = .itwtSetup
			case WIFI_EVENT_ITWT_TEARDOWN.rawValue: self = .itwtTeardown
			case WIFI_EVENT_ITWT_PROBE.rawValue: self = .itwtProbe
			case WIFI_EVENT_ITWT_SUSPEND.rawValue: self = .itwtSuspend
			case WIFI_EVENT_TWT_WAKEUP.rawValue: self = .twtWakeup
			case WIFI_EVENT_NAN_STARTED.rawValue: self = .nanStarted
			case WIFI_EVENT_NAN_STOPPED.rawValue: self = .nanStopped
			case WIFI_EVENT_NAN_SVC_MATCH.rawValue: self = .nanSvcMatch
			case WIFI_EVENT_NAN_REPLIED.rawValue: self = .nanReplied
			case WIFI_EVENT_NAN_RECEIVE.rawValue: self = .nanReceive
			case WIFI_EVENT_NDP_INDICATION.rawValue: self = .ndpIndication
			case WIFI_EVENT_NDP_CONFIRM.rawValue: self = .ndpConfirm
			case WIFI_EVENT_NDP_TERMINATED.rawValue: self = .ndpTerminated
			case WIFI_EVENT_HOME_CHANNEL_CHANGE.rawValue: self = .homeChannelChange
			default: return nil
		}
	}
}
