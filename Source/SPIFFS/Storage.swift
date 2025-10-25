
import CSPIFFS

public enum SPIFFS {
    @discardableResult
    public static func register(_ basePath: String, partition: String? = nil, maxFiles: Int, formatIfMountFailed: Bool = false) -> Bool {
        return basePath.withCString { basePath in
            let partition_str = partition ?? ""
            return partition_str.withCString { partition_str in
                let partition_ptr = partition != nil ? partition_str : nil
                var conf = esp_vfs_spiffs_conf_t(
                    base_path: basePath, partition_label: partition_ptr, max_files: maxFiles, format_if_mount_failed: formatIfMountFailed
                )

                return esp_vfs_spiffs_register(&conf) == ESP_OK
            }
        }
    }

    public static func mounted(partition: String? = nil) -> Bool {
        return esp_spiffs_mounted(partition)
    }

    public static func usage(partition: String? = nil) -> (used: Int, total: Int) {
        var used = 0
        var total = 0
        esp_spiffs_info(partition, &total, &used)
        return (used, total)
    }

    public static func check(partition: String? = nil) -> Bool {
        return esp_spiffs_check(partition) == ESP_OK
    }

    public static func collectGarbage(partition: String? = nil, size: Int) -> Bool {
        return esp_spiffs_gc(partition, size) == ESP_OK
    }
}
