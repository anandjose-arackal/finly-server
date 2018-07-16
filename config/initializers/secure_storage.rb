if ENV['REQUIRE_SECURE_STORAGE'] == 'true'
  Finly::SecureStorage::Connector.configuration do |config|
    config.keys = %w(core/finly_collect core/yes_bank core/database)
  end
end