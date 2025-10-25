#include "esp_log.h"


void log_verbose(const char * _tag, const char * message) {
    ESP_LOGV(_tag, "%s", message);
}

void log_debug(const char * _tag, const char * message) {
    ESP_LOGD(_tag, "%s", message);
}

void log_info(const char * _tag, const char * message) {
    ESP_LOGI(_tag, "%s", message);
}

void log_warn(const char * _tag, const char * message) {
    ESP_LOGW(_tag, "%s", message);
}

void log_error(const char * _tag, const char * message) {
    ESP_LOGE(_tag, "%s", message);
}
