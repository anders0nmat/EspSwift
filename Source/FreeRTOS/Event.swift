
import CFreeRTOS

public final class EventGroup<Flag: RawRepresentable> where Flag.RawValue: UnsignedInteger {
	private var handle: EventGroupHandle_t

	public init() {
		self.handle = xEventGroupCreate()
	}

	deinit {
		vEventGroupDelete(handle)
	}

	public func wait(for flag: Flag, timeout: RTOSClock.Duration, clearFlags: Bool = false) -> Bool {
		wait(for: .all, of: [flag], timeout: timeout, clearFlags: clearFlags) != nil
	}

	public func wait(for kind: WaitType, of flags: FlagSet, timeout: RTOSClock.Duration, clearFlags: Bool = false) -> FlagSet? {
		let waitForAllBits = switch kind {
			case .all: true
			case .any: false
		}

		let bitState = FlagSet(state: xEventGroupWaitBits(handle, flags.bits, clearFlags.toFreeRTOS, waitForAllBits.toFreeRTOS, timeout.ticks))

		return switch kind {
			case .all: bitState.containsAll(flags) ? bitState : nil
			case .any: bitState.containsAny(flags) ? bitState : nil
		}
	}

	public func set(_ flag: Flag) { set([flag]) }
	public func set(_ flags: FlagSet) { xEventGroupSetBits(handle, flags.bits) }

	public func clear(_ flag: Flag) { clear([flag]) }
	public func clear(_ flags: FlagSet) { xEventGroupClearBits(handle, flags.bits) }

	public func sync(set flags: FlagSet, waitFor waitFlags: FlagSet, timeout: RTOSClock.Duration) -> Bool {
		let flagState = FlagSet(state: xEventGroupSync(handle, flags.bits, waitFlags.bits, timeout.ticks))
		
		return flagState.containsAll(waitFlags)
	}
}

extension RawRepresentable where RawValue: UnsignedInteger {
	internal var bit: EventBits_t { 1 << self.rawValue }
}

extension EventGroup {
	public enum WaitType {
		case any
		case all
	}

	public struct FlagSet: ExpressibleByArrayLiteral {
		public internal(set) var bits: EventBits_t

		internal init() {
			self.bits = 0
		}

		public init(flags: [Flag]) {
			self.init(state: flags.reduce(0 as EventBits_t) { $0 | $1.bit })
		}

		public init(arrayLiteral elements: Flag...) {
			self.init(flags: elements)
		}

		internal init(state: EventBits_t) {
			self.bits = state
		}

		public func contains(_ flag: Flag) -> Bool { bits & flag.bit != 0 }
		public func containsAll(_ other: FlagSet) -> Bool { ~bits & other.bits == 0 }
		public func containsAny(_ other: FlagSet) -> Bool { bits & other.bits != 0 }

		internal mutating func set(_ flag: Flag) { bits |= flag.bit }
		internal mutating func reset(_ flag: Flag) { bits &= ~flag.bit }
	}
}
