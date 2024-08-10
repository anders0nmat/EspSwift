
import CFreeRTOS

public enum RTOSClock {
	public struct Instant {
		public typealias Duration = RTOSClock.Duration

		public let ticks: TickType_t

		public init(ticks: TickType_t) {
			self.ticks = ticks
		}

		public func duration(to other: Self) -> Duration {
			let diff = self.ticks.distance(to: other.ticks)
			return Duration(ticks: TickType_t(clamping: diff.magnitude))
		}

		public func advanced(by duration: Duration) -> Self {
			return Self(ticks: self.ticks + duration.ticks)
		}

		public static var now: Self { Self(ticks: xTaskGetTickCount()) }
	}

	public struct Duration {
		public let ticks: TickType_t

		public init(ticks: TickType_t) {
			self.ticks = ticks
		}

		public init(
		hours: UInt32 = 0,
		minutes: UInt32 = 0,
		seconds: UInt32 = 0,
		milliseconds: UInt32 = 0) {
			let totalMs = 
				hours * 60 * 60 * 1000 +
				minutes * 60 * 1000 +
				seconds * 1000 +
				milliseconds
			self.init(ticks: totalMs / freertos_portTICK_PERIOD_MS)
		}

		public static func hours(_ value: UInt32)        -> Self { Self(hours: value) }
		public static func minutes(_ value: UInt32)      -> Self { Self(minutes: value) }
		public static func seconds(_ value: UInt32)      -> Self { Self(seconds: value) }
		public static func milliseconds(_ value: UInt32) -> Self { Self(milliseconds: value) }

		public static var maximum: Self { Self(ticks: portMAX_DELAY) }
	}
}

extension RTOSClock.Instant: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.ticks < rhs.ticks }
}

extension RTOSClock.Instant {
	public static func + (lhs: Self, rhs: Self.Duration) -> Self { lhs.advanced(by: rhs) }
	public static func += (lhs: inout Self, rhs: Self.Duration) { lhs = lhs + rhs }
	public static func - (lhs: Self, rhs: Self.Duration) -> Self { Self(ticks: lhs.ticks - rhs.ticks) }
	public static func - (lhs: Self, rhs: Self) -> Self.Duration { lhs.duration(to: rhs) }
	public static func -= (lhs: inout Self, rhs: Self.Duration) { lhs = lhs - rhs }
}

extension RTOSClock.Duration: AdditiveArithmetic, Comparable {
    public static var zero: Self { Self(ticks: 0) }
    public static func + (lhs: Self, rhs: Self) -> Self { Self(ticks: lhs.ticks + rhs.ticks) }
	public static func - (lhs: Self, rhs: Self) -> Self { Self(ticks: lhs.ticks - rhs.ticks) }
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.ticks < rhs.ticks }
}

