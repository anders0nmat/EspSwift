
import CNVS

public struct NVS: ~Copyable {
	internal let handle: nvs_handle_t
	internal let autoCommit: Bool

	public var keys: NVSKeySequence { .init(self) }
	public func keys(ofType type: DataType) -> NVSKeySequence { .init(self, type: type) }

	public var entryCount: Int {
		var value = 0
		nvs_get_used_entry_count(handle, &value)
		return value
	}

	public init(namespace: String, mode: OpenMode = .readWrite, initPartition: Bool = true, autoCommit: Bool = true) {
		if initPartition {
			nvs_flash_init()
		}

		var handle = nvs_handle_t()
		nvs_open(namespace, mode.rawValue, &handle)
		self.handle = handle
		self.autoCommit = autoCommit
	}

	public init(partition: String, namespace: String, mode: OpenMode = .readWrite, initPartition: Bool = true, autoCommit: Bool = true) {
		if initPartition {
			nvs_flash_init_partition(partition)
		}

		var handle = nvs_handle_t()
		nvs_open_from_partition(partition, namespace, mode.rawValue, &handle)
		self.handle = handle
		self.autoCommit = autoCommit
	}

	deinit {
		if autoCommit { commit() }
		nvs_close(handle)
	}

	public subscript<Value: NVSStorable>(key: String) -> Value {
		get { Value(from: self, forKey: key) }
		nonmutating set { newValue.encode(to: self, forKey: key) }
	}

	public func commit() {
		nvs_commit(handle)
	}

	public func valueType(of key: String) -> DataType? {
		var value = NVS_TYPE_ANY
		switch nvs_find_key(handle, key, &value) {
			case ESP_OK: return DataType(rawValue: value)
			case ESP_ERR_NVS_NOT_FOUND_shim: return nil
			default: return nil
		}
	}

	public func contains(_ key: String) -> Bool { valueType(of: key) != nil }
	public func delete(key: String) { nvs_erase_key(handle, key) }
	public func deleteAllKeys() { nvs_erase_all(handle) }
}

extension NVS {
	@discardableResult
	public static func initDefault() -> Bool {
		return nvs_flash_init() == ESP_OK
	}

	@discardableResult
	public static func initPartition(_ name: String) -> Bool {
		return nvs_flash_init_partition(name) == ESP_OK
	}

	public static func deinitDefault() {
		nvs_flash_deinit()
	}

	public static func deinitPartition(_ name: String) {
		nvs_flash_deinit_partition(name)
	}

	public static func eraseDefault() {
		nvs_flash_erase()
	}

	public static func erasePartition(_ name: String) {
		nvs_flash_erase_partition(name)
	}

	public static func getStats() -> NVSStatistics {
		var stats = nvs_stats_t()
		nvs_get_stats(nil, &stats)
		return .init(stats: stats)
	}

	public static func getStats(for partition: String) -> NVSStatistics {
		var stats = nvs_stats_t()
		nvs_get_stats(partition, &stats)
		return .init(stats: stats)
	}
}

extension NVS {
	public enum OpenMode {
		case readOnly
		case readWrite

		internal var rawValue: nvs_open_mode_t {
			switch self {
				case .readOnly: NVS_READONLY
				case .readWrite: NVS_READWRITE
			}
		}
	}

	public enum DataType {
		case u8, u16, u32, u64
		case i8, i16, i32, i64
		case str, blob
		case any

		internal init(rawValue: nvs_type_t) {
			switch rawValue {
				case NVS_TYPE_U8: self = .u8
				case NVS_TYPE_U16: self = .u16
				case NVS_TYPE_U32: self = .u32
				case NVS_TYPE_U64: self = .u64

				case NVS_TYPE_I8: self = .i8
				case NVS_TYPE_I16: self = .i16
				case NVS_TYPE_I32: self = .i32
				case NVS_TYPE_I64: self = .i64

				case NVS_TYPE_STR: self = .str
				case NVS_TYPE_BLOB: self = .blob
				case NVS_TYPE_ANY: self = .any

				default: fatalError()
			}
		}

		internal var rawValue: nvs_type_t {
			switch self {
				case .u8: NVS_TYPE_U8
				case .u16: NVS_TYPE_U16
				case .u32: NVS_TYPE_U32
				case .u64: NVS_TYPE_U64

				case .i8: NVS_TYPE_I8
				case .i16: NVS_TYPE_I16
				case .i32: NVS_TYPE_I32
				case .i64: NVS_TYPE_I64

				case .str: NVS_TYPE_STR
				case .blob: NVS_TYPE_BLOB
				case .any: NVS_TYPE_ANY
			}
		}
	}
}

