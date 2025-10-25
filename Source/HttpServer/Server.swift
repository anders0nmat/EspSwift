import CHttpServer
import CClosures
import Logging

let logger = Logger("HttpServer")

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
	public typealias HttpHandler = (inout Request) -> Void
	private typealias HttpHandlerClosure = Closure<HttpHandler>
	private var handle: httpd_handle_t!
	private var handlers: [HttpHandlerClosure]

	public init(
        matchUriWildcard: Bool = false,
    ) throws(HttpServerError) {
		self.handle = nil
		self.handlers = []

		var config = httpd_default_config()
		config.global_user_ctx = Unmanaged.passUnretained(self).toOpaque()

        if matchUriWildcard {
            config.uri_match_fn = httpd_uri_match_wildcard
        }

		var handle: httpd_handle_t?
		switch httpd_start(&handle, &config) {
			case ESP_OK: break
			case ESP_ERR_INVALID_ARG: throw HttpServerError.invalidArgument
			case _ESP_ERR_HTTPD_ALLOC_MEM: throw HttpServerError.allocationFailed
			case _ESP_ERR_HTTPD_TASK: throw HttpServerError.taskCreateFailed
			case let code: throw HttpServerError.unknown(errorCode: code) 
		}
		
		guard let handle else { fatalError("httpd_start() returned OK but handle is still nil") }
		self.handle = handle
	}


	deinit {
		httpd_stop(handle)
	}

	public func register(_ method: HttpMethod, _ uri: String, handler: @escaping HttpHandler) {
		let closure = HttpHandlerClosure(closure: handler)
		handlers.append(closure)
		uri.withCString { uriCString in
			var uri_config = httpd_uri_t(
				uri: uriCString,
				method: method.rawValue,
				handler: { req in
					guard let req else { fatalError("recieved request without request object") }
					let handler = HttpHandlerClosure.fromOpaque(req.pointee.user_ctx)
                    var request = Request(handle: req)
                    handler.closure(&request)
					return request.success ? ESP_OK : ESP_FAIL
				},
				user_ctx: closure.toOpaque())

			switch httpd_register_uri_handler(handle, &uri_config) {
                case ESP_OK: break
                case ESP_ERR_INVALID_ARG: logger.warn("Invalid Argument")
                case _ESP_ERR_HTTPD_HANDLERS_FULL: logger.warn("Handlers are full")
                case _ESP_ERR_HTTPD_HANDLER_EXISTS: logger.info("Handler already registered")
                case let errorCode: logger.warn("Registering uri handler failed with code " + errorCode.description)
            }
		}
	}

	public func unregister(_ method: HttpMethod, _ uri: String) {
		httpd_unregister_uri_handler(handle, uri, method.rawValue)
	}

	public func unregister(_ uri: String) {
		httpd_unregister_uri(handle, uri)
	}
}

