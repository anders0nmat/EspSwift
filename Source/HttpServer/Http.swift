
import CHttpServer

public enum HttpMethod {
	// Default HTTP Methods
	case DELETE, GET, HEAD, POST, PUT

	internal init?(rawValue: http_method) {
		switch rawValue {
			case HTTP_DELETE: self = .DELETE
			case HTTP_GET: self = .GET
			case HTTP_HEAD: self = .HEAD
			case HTTP_POST: self = .POST
			case HTTP_PUT: self = .PUT
			default: return nil
		}
	}

	internal var rawValue: httpd_method_t {
		switch self {
			case .DELETE: return HTTP_DELETE
			case .GET: return HTTP_GET
			case .HEAD: return HTTP_HEAD
			case .POST: return HTTP_POST
			case .PUT: return HTTP_PUT
		}
	}
}

public enum HttpStatus {
	case OK

	case custom(String)

	internal var value: String {
		switch self {
			case .OK: "200 OK"
			case .custom(let customStatus): customStatus
		}
	}
}

public enum HttpErrorStatus {
	case BadRequest
	case Unauthorized
	case Forbidden
	case NotFound
	case MethodNotAllowed
	case RequestTimeout
	case LengthRequired
	case UriTooLong
	case RequestHeaderTooLarge

	case InternalServerError
	case MethodNotImplemented
	case VersionNotSupported

	internal var value: httpd_err_code_t {
		switch self {
			case .BadRequest: HTTPD_400_BAD_REQUEST
			case .Unauthorized: HTTPD_401_UNAUTHORIZED
			case .Forbidden: HTTPD_403_FORBIDDEN
			case .NotFound: HTTPD_404_NOT_FOUND
			case .MethodNotAllowed: HTTPD_405_METHOD_NOT_ALLOWED
			case .RequestTimeout: HTTPD_408_REQ_TIMEOUT
			case .LengthRequired: HTTPD_411_LENGTH_REQUIRED
			case .UriTooLong: HTTPD_414_URI_TOO_LONG
			case .RequestHeaderTooLarge: HTTPD_431_REQ_HDR_FIELDS_TOO_LARGE
			
			case .InternalServerError: HTTPD_500_INTERNAL_SERVER_ERROR
			case .MethodNotImplemented: HTTPD_501_METHOD_NOT_IMPLEMENTED
			case .VersionNotSupported: HTTPD_505_VERSION_NOT_SUPPORTED
		}
	}
}

public enum HttpContentType {
	case html
	case custom(String)

	internal var value: String {
		switch self {
			case .html: "text/html"
			case .custom(let customValue): customValue
		}
	}
}
