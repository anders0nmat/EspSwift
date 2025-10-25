
import CNVS

public struct NVSStatistics {
	public let usedEntries: Int
	public let freeEntries: Int
	public let availableEntries: Int
	public let totalEntries: Int
	public let namespaceCount: Int

	internal init(stats: nvs_stats_t) {
		self.usedEntries = stats.used_entries
		self.freeEntries = stats.free_entries
		self.availableEntries = stats.available_entries
		self.totalEntries = stats.total_entries
		self.namespaceCount = stats.namespace_count
	}
}
