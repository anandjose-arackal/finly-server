SecureStorage::Connector.configuration do |config|
  config.keys = %w(core/finly_collect core/yes_bank core/database)
  config.local = true
end