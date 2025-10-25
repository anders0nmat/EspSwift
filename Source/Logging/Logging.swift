
import CLogging

public struct Logger: Sendable {
    internal let tag: StaticString

    public init(_ tag: StaticString) {
        self.tag = tag
    }

    public func verbose(_ message: String) {
        log_verbose(tag.utf8Start, message)
    }

    public func debug(_ message: String) {
        log_debug(tag.utf8Start, message)
    }

    public func info(_ message: String) {
        log_info(tag.utf8Start, message)
    }

    public func warn(_ message: String) {
        log_warn(tag.utf8Start, message)
    }

    public func error(_ message: String) {
        log_error(tag.utf8Start, message)
    }
}
