
import CFreeRTOS

extension Bool {
	internal init(_ rtosValue: BaseType_t) {
		self = rtosValue == pdTRUE
	}
	internal var toFreeRTOS: BaseType_t { self ? pdTRUE : pdFALSE }
}
