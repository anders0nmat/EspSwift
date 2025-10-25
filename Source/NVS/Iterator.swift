
import CNVS

public final class NVSKeySequence: Sequence, IteratorProtocol {
	internal var iterator: nvs_iterator_t?

	internal init(_ storage: borrowing NVS, type: NVS.DataType = .any) {
		nvs_entry_find_in_handle(storage.handle, type.rawValue, &self.iterator)
	}

	deinit {
		nvs_release_iterator(self.iterator)
	}

    public func next() -> (String, NVS.DataType)? {
		guard let iterator else { return nil }
		defer { nvs_entry_next(&self.iterator) }

		return getKey(from: iterator)
	}

	internal func getKey(from iterator: nvs_iterator_t) -> (String, NVS.DataType) {
		var info = nvs_entry_info_t()
		nvs_entry_info(iterator, &info)

		return (
			String(cString: nvs_entry_get_key(&info)),
			.init(rawValue: info.type)
		)
	}
}
