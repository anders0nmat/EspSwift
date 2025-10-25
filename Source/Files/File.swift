
import CFiles

public enum FileMode: String {
    case read = "r"
    case write = "w"
    case append = "a"
    case readUpdate = "r+"
    case writeUpdate = "w+"
    case appendUpdate = "a+"
}

public struct File: ~Copyable {
    internal let fd: UnsafeMutablePointer<FILE>

    deinit {
        fclose(fd)
    }

    public static func open(_ filename: String, mode: FileMode = .read) -> File {
        let fd = fopen(filename, mode.rawValue)
        return File(fd: fd!)
    }

    @discardableResult
    public func read(_ buffer: inout Buffer) -> Int {
        let bytesRead = fread(buffer.start, 1, buffer.size, fd)
        buffer.count = bytesRead
        return bytesRead
    }

    public func readAsString() -> String {
        var buffer = Buffer(size: size)
        read(&buffer)
        return String(decoding: buffer.data, as: UTF8.self)
    }

    public func write(_ content: String) {
        content.withCString {
            _ = fputs($0, fd)
        }
    }

    public var isError: Bool { ferror(fd) != 0 }
    public var isEof: Bool { feof(fd) != 0 }
    public var size: Int {
        let current_pos = ftell(fd)
        fseek(fd, 0, SEEK_END)
        let size = ftell(fd)
        fseek(fd, current_pos, SEEK_SET)
        return size
    }
}
