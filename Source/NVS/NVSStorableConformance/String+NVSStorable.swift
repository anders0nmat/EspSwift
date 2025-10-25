
import CNVS

extension String: NVSStorable {
	public init(from storage: borrowing NVS, forKey: String) {
		var stringLength = 0
		nvs_get_str(storage.handle, forKey, nil, &stringLength)
		
		let data = UnsafeMutablePointer<CChar>.allocate(capacity: stringLength)
		defer { data.deallocate() }

		nvs_get_str(storage.handle, forKey, data, &stringLength)

		self = String(cString: data)		
    }

    public func encode(to storage: borrowing NVS, forKey: String) {
		withCString { cString in
			nvs_set_str(storage.handle, forKey, cString)
			return
		}
    }
}
