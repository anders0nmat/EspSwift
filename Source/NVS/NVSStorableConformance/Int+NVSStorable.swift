import CNVS

extension UInt8: NVSStorable {
    public init(from storage: borrowing NVS, forKey: String) {
		var value = Self()
		nvs_get_u8(storage.handle, forKey, &value)
		self = value
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		nvs_set_u8(storage.handle, forKey, self)
    }
}

extension UInt16: NVSStorable {
    public init(from storage: borrowing NVS, forKey: String) {
		var value = Self()
		nvs_get_u16(storage.handle, forKey, &value)
		self = value
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		nvs_set_u16(storage.handle, forKey, self)
    }
}

extension UInt32: NVSStorable {
    public init(from storage: borrowing NVS, forKey: String) {
		var value = Self()
		nvs_get_u32(storage.handle, forKey, &value)
		self = value
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		nvs_set_u32(storage.handle, forKey, self)
    }
}

extension UInt64: NVSStorable {
    public init(from storage: borrowing NVS, forKey: String) {
		var value = Self()
		nvs_get_u64(storage.handle, forKey, &value)
		self = value
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		nvs_set_u64(storage.handle, forKey, self)
    }
}

extension Int8: NVSStorable {
    public init(from storage: borrowing NVS, forKey: String) {
		var value = Self()
		nvs_get_i8(storage.handle, forKey, &value)
		self = value
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		nvs_set_i8(storage.handle, forKey, self)
    }
}

extension Int16: NVSStorable {
    public init(from storage: borrowing NVS, forKey: String) {
		var value = Self()
		nvs_get_i16(storage.handle, forKey, &value)
		self = value
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		nvs_set_i16(storage.handle, forKey, self)
    }
}

extension Int32: NVSStorable {
    public init(from storage: borrowing NVS, forKey: String) {
		var value = Self()
		nvs_get_i32(storage.handle, forKey, &value)
		self = value
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		nvs_set_i32(storage.handle, forKey, self)
    }
}

extension Int64: NVSStorable {
    public init(from storage: borrowing NVS, forKey: String) {
		var value = Self()
		nvs_get_i64(storage.handle, forKey, &value)
		self = value
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		nvs_set_i64(storage.handle, forKey, self)
    }
}
