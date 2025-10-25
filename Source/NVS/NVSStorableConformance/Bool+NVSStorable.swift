
extension Bool: NVSStorable {
    public init(from storage: borrowing NVS, forKey: String) {
		let val = UInt8(from: storage, forKey: forKey)
		self = val != 0
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		let val: UInt8 = self ? 1 : 0
		val.encode(to: storage, forKey: forKey)
    }
}
