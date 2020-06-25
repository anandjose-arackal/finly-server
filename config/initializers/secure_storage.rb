if Rails.env.production?
  Finly::SecureStorage::Connector.configuration do |config|
      config.keys = %w(core/finly_collect core/yes_bank core/icici_bank core/database core/kotak_bank)
  end
end