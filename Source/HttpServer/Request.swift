
import CHttpServer

public struct Request {
	private var handle: UnsafeMutablePointer<httpd_req_t>

	internal init(handle: UnsafeMutablePointer<httpd_req_t>) {
		self.handle = handle
		self.query = Query(handle: handle)
	}

	public var method: HttpMethod? {
		if let method = UInt32(exactly: handle.pointee.method) {
			return HttpMethod(rawValue: httpd_method_t(method))
		}
		return nil
	}

	public var uri: String {
		// Functionally the same code but swift-native variant brings lsp to struggle
		// Therefore, helper function httpd_req_get_uri in CHttpServer
		/*withUnsafeBytes(of: handle.pointee.uri) { (rawPtr) -> String in
			let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
			return String(cString: ptr)
		}*/
		String(cString: httpd_req_get_uri(handle))
	}

	public var contentLength: Int { handle.pointee.content_len }

	public var headers: Header { Header(handle: handle) }
	public var query: Query

	public func contentString() -> String {
		guard contentLength > 0 else { return "" }

		let data = UnsafeMutablePointer<CChar>.allocate(capacity: contentLength + 1)
		defer { data.deallocate() }

		httpd_req_recv(handle, data, contentLength + 1)
		return String(cString: data)
	}

	public func contentBytes() -> [UInt8] {
		guard contentLength > 0 else { return [] }

		return Array<UInt8>(unsafeUninitializedCapacity: contentLength) { buf, count in
			count = Int(httpd_req_recv(handle, buf.baseAddress, contentLength))
		}
	}

	internal func respond(content: UnsafeBufferPointer<UInt8>, status: HttpStatus, contentType: HttpContentType, extraHeaders: [(String, String)]) {
		httpd_resp_set_status(handle, status.value)
		httpd_resp_set_type(handle, contentType.value)

		for (key, value) in extraHeaders {
			httpd_resp_set_hdr(handle, key, value)
		}

		httpd_resp_send(handle, content.baseAddress, content.count)
	}

	public func respond(with content: String, status: HttpStatus = .OK, contentType: HttpContentType = .html, extraHeaders: [(String, String)] = []) {
		var content = content
		content.withUTF8 { ptr in
			respond(content: ptr, status: status, contentType: contentType, extraHeaders: extraHeaders)
		}
	}

	public func respond(with content: [UInt8], status: HttpStatus = .OK, contentType: HttpContentType = .html, extraHeaders: [(String, String)] = []) {
		content.withUnsafeBufferPointer { ptr in
			respond(content: ptr, status: status, contentType: contentType, extraHeaders: extraHeaders)
		}
	}

	public func respond(_ error: HttpErrorStatus, message: String? = nil) {
		if message == nil {
			httpd_resp_send_err(handle, error.value, UnsafePointer<CChar>(bitPattern: 0))
		}
		else {
			httpd_resp_send_err(handle, error.value, message)
		}
	}

	public func respond(status: HttpStatus = .OK, contentType: HttpContentType = .html, extraHeaders: [(String, String)] = [], content: (ChunkedResponseSender) -> Void) {
		httpd_resp_set_status(handle, status.value)
		httpd_resp_set_type(handle, contentType.value)

		for (key, value) in extraHeaders {
			httpd_resp_set_hdr(handle, key, value)
		}

		content(ChunkedResponseSender(handle: handle))

		httpd_resp_send_chunk(handle, UnsafePointer<CChar>(bitPattern: 0), 0)
	}
}

extension Request {
	public struct Header {
		private let handle: UnsafeMutablePointer<httpd_req_t>

		internal init(handle: UnsafeMutablePointer<httpd_req_t>) {
			self.handle = handle
		}

		public subscript(headerName: String) -> String? {
			let fieldSize = httpd_req_get_hdr_value_len(handle, headerName)
			guard fieldSize > 0 else { return nil }
	
			let data = UnsafeMutablePointer<CChar>.allocate(capacity: fieldSize + 1)
			defer { data.deallocate() }
	
			httpd_req_get_hdr_value_str(handle, headerName, data, fieldSize + 1)
			return String(cString: data)
		}
	}

	public final class Query {
		private var handle: UnsafeMutablePointer<httpd_req_t>
		private var _queryString: String?
		public var queryString: String {
			if _queryString == nil {
				let fieldSize = httpd_req_get_url_query_len(handle)
				guard fieldSize > 0 else { return "" }

				let data = UnsafeMutablePointer<CChar>.allocate(capacity: fieldSize + 1)
				defer { data.deallocate() }

				httpd_req_get_url_query_str(handle, data, fieldSize + 1)
				_queryString = String(cString: data)	
			}
			return _queryString!
		}
		
		internal init(handle: UnsafeMutablePointer<httpd_req_t>) {
			self.handle = handle
		}
	}

	public struct ChunkedResponseSender {
		private let handle: UnsafeMutablePointer<httpd_req_t>

		internal init(handle: UnsafeMutablePointer<httpd_req_t>) {
			self.handle = handle
		}

		public func callAsFunction(_ content: String) {
			httpd_resp_sendstr_chunk(handle, content)
		}

		public func callAsFunction(_ content: [UInt8]) {
			content.withUnsafeBufferPointer { ptr in
				_ = httpd_resp_send_chunk(handle, ptr.baseAddress, content.count)	
			}
		}
	}
}
