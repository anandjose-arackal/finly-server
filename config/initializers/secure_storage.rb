if $secure_storage_cache.nil?
  $secure_storage_cache = ActiveSupport::Cache::MemoryStore.new
end
# SecureStorage.load(ENV['SECURE_STORAGE_USERNAME'], ENV['SECURE_STORAGE_PASSWORD'])
unless SecureStorage.loaded?
  SecureStorage.load(ENV['SECURE_STORAGE_USERNAME'], ENV['SECURE_STORAGE_PASSWORD'])
end