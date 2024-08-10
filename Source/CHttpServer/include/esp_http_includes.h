
#include "esp_http_server.h"

httpd_config_t httpd_default_config() {
	httpd_config_t default_config = HTTPD_DEFAULT_CONFIG();
	return default_config;
}

// Helper function because static arrays make swift LSP struggle a bit
const char* httpd_req_get_uri(httpd_req_t* request) {
	return request->uri;
}
