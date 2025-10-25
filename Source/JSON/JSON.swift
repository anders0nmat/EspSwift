
import CJSON
import Files

public struct JSONDocument: ~Copyable {
    var handle: UnsafeMutablePointer<cJSON>

    init(handle: UnsafeMutablePointer<cJSON>) {
        self.handle = handle
    }

    public init(from string: String) {
        self.init(handle: cJSON_Parse(string))
    }

    public init(file: String) {
        let textContent = File.open(file).readAsString()
        self.init(handle: cJSON_Parse(textContent))
    }

    deinit {
        cJSON_Delete(handle)
    }

    public subscript(key: String) -> JSONValue? {
        .init(cJSON_GetObjectItemCaseSensitive(handle, key))
    }

    public subscript(index: Int) -> JSONValue {
        .init(handle: cJSON_GetArrayItem(handle, Int32(index)))
    }

    public func append(_ value: String) {
        let jsonValue = cJSON_CreateString(value)
        cJSON_AddItemToArray(handle, jsonValue)
    }

    public func append(_ value: Int) {
        let jsonValue = cJSON_CreateNumber(Double(value))
        cJSON_AddItemToArray(handle, jsonValue)
    }

    public func append(_ value: [Int32]) {
        value.withUnsafeBufferPointer {
            let jsonValue = cJSON_CreateIntArray($0.baseAddress, Int32(value.count))
            cJSON_AddItemToArray(handle, jsonValue)
        }
    }

    public func add(key: String, value: Int32) {
        cJSON_AddNumberToObject(handle, key, Double(value))
    }

    public func print() -> String {
        let cPrint = cJSON_PrintUnformatted(handle)
        defer { free(cPrint) }
        return String(cString: cPrint!)
    }
}

public struct JSONValue {
    var handle: UnsafeMutablePointer<cJSON>

    init?(_ handle: UnsafeMutablePointer<cJSON>?) {
        guard let handle else { return nil }
        self.init(handle: handle)
    }

    init(handle: UnsafeMutablePointer<cJSON>) {
        self.handle = handle
    }

    public var isNumber: Bool { cJSON_IsNumber(handle) != 0 }
    public var isString: Bool { cJSON_IsString(handle) != 0 }
    public var isBool: Bool { cJSON_IsFalse(handle) != 0 || cJSON_IsTrue(handle) != 0 }
    public var isNull: Bool { cJSON_IsNull(handle) != 0 }
    public var isObject: Bool { cJSON_IsObject(handle) != 0 }
    public var isArray: Bool { cJSON_IsArray(handle) != 0 }

    public var stringValue: String { isString ? String(cString: handle.pointee.valuestring) : "" }
    public var intValue: Int { isNumber ? Int(handle.pointee.valueint) : 0 }
    public var floatValue: Double { isNumber ? handle.pointee.valuedouble : 0.0 }
    public var boolValue: Bool { cJSON_IsTrue(handle) != 0 }

    public var count: Int { isArray || isObject ? Int(cJSON_GetArraySize(handle)) : 0 }

    public subscript(key: String) -> JSONValue? {
        .init(cJSON_GetObjectItemCaseSensitive(handle, key))
    }

    public subscript(index: Int) -> JSONValue {
        .init(cJSON_GetArrayItem(handle, Int32(index)))!
    }

    public func at(index: Int) -> JSONValue? {
        guard isArray else { return nil }
        let count = self.count
        guard (-count..<count).contains(index) else { return nil }

        return self[index < 0 ? count - index : index]
    }

    public func has(key: String) -> Bool {
        cJSON_HasObjectItem(handle, key) != 0
    }
}
