


public protocol NVSStorable {
	init(from storage: borrowing NVS, forKey: String)
	func encode(to storage: borrowing NVS, forKey: String)
}

