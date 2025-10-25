
public struct Buffer: ~Copyable {
    public let data: UnsafeMutableBufferPointer<UInt8>
    public var count: Int
    
    public var size: Int { data.count }
    public var isEmpty: Bool { count == 0 }

    public var start: UnsafeMutablePointer<UInt8> { data.baseAddress! }

    public init(size: Int) {
        self.data = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: size)
        self.count = 0
    }

    deinit {
        data.deallocate()
    }
}
