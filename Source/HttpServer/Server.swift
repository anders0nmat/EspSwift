import CHttpServer
import CClosures

public enum HttpServerError: Error {
	case invalidArgument
	
	// server creation
	case allocationFailed
	case taskCreateFailed
	
	// handler registration
	case handlersFull
	case handlerExists

	case unknown(errorCode: esp_err_t)
}

public enum HttpHandleResult {
	case success
	case failure
}

public final class HttpServer {
	public typealias HttpHandler = (Request) -> HttpHandleResult
	private typealias HttpHandlerClosure = Closure<HttpHandler>
	private var handle: httpd_handle_t!
	private var handlers: [HttpHandlerClosure]

	public init() throws(HttpServerError) {
		self.handle = nil
		self.handlers = []

		var config = httpd_default_config()
		config.global_user_ctx = Unmanaged.passUnretained(self).toOpaque()

		var handle: httpd_handle_t?
		switch httpd_start(&handle, &config) {
			case ESP_OK: break
			case ESP_ERR_INVALID_ARG: throw HttpServerError.invalidArgument
			case ESP_ERR_HTTPD_ALLOC_MEM: throw HttpServerError.allocationFailed
			case ESP_ERR_HTTPD_TASK: throw HttpServerError.taskCreateFailed
			case let code: throw HttpServerError.unknown(errorCode: code) 
		}
		
		guard let handle else { fatalError("httpd_start() returned OK but handle is still nil") }
		self.handle = handle
	}

	deinit {
		httpd_stop(handle)
	}

	public func register(_ method: HttpMethod, _ uri: String, handler: @escaping (Request) -> HttpHandleResult) throws(HttpServerError) {
		let closure = HttpHandlerClosure(closure: handler)
		handlers.append(closure)
		var success: esp_err_t = ESP_FAIL
		uri.withCString { uriCString in
			var uri_config = httpd_uri_t(
				uri: uriCString,
				method: method.rawValue,
				handler: { req in
					guard let req else { fatalError("recieved request without request object") }
					let handler = HttpHandlerClosure.fromOpaque(req.pointee.user_ctx)
					return switch handler.closure(Request(handle: req)) {
						case .success: ESP_OK
						case .failure: ESP_FAIL
					}
				},
				user_ctx: closure.toOpaque())

			success = httpd_register_uri_handler(handle, &uri_config) 
		}
		switch success {
			case ESP_OK: break
			case ESP_ERR_INVALID_ARG: throw HttpServerError.invalidArgument
			case ESP_ERR_HTTPD_HANDLERS_FULL: throw HttpServerError.handlersFull
			case ESP_ERR_HTTPD_HANDLER_EXISTS: throw HttpServerError.handlerExists
			case let errorCode: throw HttpServerError.unknown(errorCode: errorCode)
		}
	}

	public func unregister(_ method: HttpMethod, _ uri: String) {
		httpd_unregister_uri_handler(handle, uri, method.rawValue)
	}

	public func unregister(_ uri: String) {
		httpd_unregister_uri(handle, uri)
	}
}

/* register() overloads */
extension HttpServer {
	public func register(_ method: HttpMethod, _ uri: String, handler: @escaping (Request) -> Void) throws(HttpServerError) {
		try register(method, uri) { req in
			handler(req)
			return .success
		}
	}

	public func register(_ method: HttpMethod, _ uri: String, handler: @escaping (Request) throws -> Void) throws(HttpServerError) {
		try register(method, uri) { req in
			do {
				try handler(req)
				return .success
			}
			catch {
				return .failure
			}
		}
	}
}
