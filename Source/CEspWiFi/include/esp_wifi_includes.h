
#include "nvs_flash.h"
#include "esp_system.h"
#include "esp_event.h"
#include "esp_wifi.h"

wifi_init_config_t esp_wifi_config_default() {
	wifi_init_config_t defaultConfig = WIFI_INIT_CONFIG_DEFAULT();
	return defaultConfig;
}

void esp_wifi_copy_static_string(char* destination, const char* source, size_t maxcount) {
	for (int i = 0; i < maxcount && *source != '\0'; i++) {
		*destination++ = *source++;
	}
}
