
#include "nvs_flash.h"

const char* nvs_entry_get_key(nvs_entry_info_t* info) {
	return info->key;
}

const int ESP_ERR_NVS_NOT_FOUND_shim = ESP_ERR_NVS_NOT_FOUND;

