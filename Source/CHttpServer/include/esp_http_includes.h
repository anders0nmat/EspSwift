
#include "esp_http_server.h"

httpd_config_t httpd_default_config() {
	httpd_config_t default_config = HTTPD_DEFAULT_CONFIG();
	return default_config;
}

// Helper function because static arrays make swift LSP struggle a bit
const char* httpd_req_get_uri(httpd_req_t* request) {
	return request->uri;
}

namespace httpd_shims {
	const esp_err_t _ESP_ERR_HTTPD_ALLOC_MEM = ESP_ERR_HTTPD_ALLOC_MEM;
	const esp_err_t _ESP_ERR_HTTPD_TASK = ESP_ERR_HTTPD_TASK;
	const esp_err_t _ESP_ERR_HTTPD_HANDLERS_FULL = ESP_ERR_HTTPD_HANDLERS_FULL;
	const esp_err_t _ESP_ERR_HTTPD_HANDLER_EXISTS = ESP_ERR_HTTPD_HANDLER_EXISTS;
}
