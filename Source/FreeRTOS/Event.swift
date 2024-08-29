
import CFreeRTOS

public protocol BitSet: OptionSet where RawValue == EventBits_t {}

extension BitSet {
	public init<Bit: FixedWidthInteger>(bit: Bit) { self.init(rawValue: 1 << bit) }
}

public final class EventGroup<FlagSet: BitSet> {
	private var handle: EventGroupHandle_t

	public init() {
		self.handle = xEventGroupCreate()
	}

	deinit {
		vEventGroupDelete(handle)
	}

	public func wait(for flags: FlagSet, _ kind: WaitType = .all, timeout: RTOSClock.Duration, clearFlags: Bool = false) -> FlagSet? {
		let bitState = FlagSet(rawValue: xEventGroupWaitBits(handle, flags.rawValue, clearFlags.toFreeRTOS, kind.waitForAll.toFreeRTOS, timeout.ticks))

		switch kind {
			case .all: return  bitState.isSuperset(of: flags)   ? bitState : nil
			case .any: return !bitState.isDisjoint(with: flags) ? bitState : nil
		}
	}

	public func set(_ flags: FlagSet) { xEventGroupSetBits(handle, flags.rawValue) }
	public func clear(_ flags: FlagSet) { xEventGroupClearBits(handle, flags.rawValue) }

	public func sync(set flags: FlagSet, waitFor waitFlags: FlagSet, timeout: RTOSClock.Duration) -> Bool {
		let flagState = FlagSet(rawValue: xEventGroupSync(handle, flags.rawValue, waitFlags.rawValue, timeout.ticks))
		return flagState.isSuperset(of: waitFlags)
	}
}

extension EventGroup {
	public enum WaitType {
		case any
		case all

		internal var waitForAll: Bool {
			switch self {
				case .all: true
				case .any: false
			}	
		}
	}
}
