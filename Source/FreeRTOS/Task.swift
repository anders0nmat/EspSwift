
import CFreeRTOS

public struct Task {
	public static func delay(for duration: RTOSClock.Duration) {
		vTaskDelay(duration.ticks)
	}

	@discardableResult
	public static func delay(from instant: inout RTOSClock.Instant, for duration: RTOSClock.Duration) -> Bool {
		var startTicks = instant.ticks

		let result = Bool(xTaskDelayUntil(&startTicks, duration.ticks))
		instant = RTOSClock.Instant(ticks: startTicks)
		return result
	}
}
