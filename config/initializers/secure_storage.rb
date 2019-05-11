if Rails.env.production?
  Finly::SecureStorage::Connector.configuration do |config|
      config.keys = %w(core/finly_collect core/yes_bank core/database core/master_users core/whitelisted_ip_list)
  end
end