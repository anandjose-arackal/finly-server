if Rails.env.production? and Socket.gethostname == 'finly-core-bgp'
  Finly::SecureStorage::Connector.configuration do |config|
      config.keys = %w(core/finly_collect core/yes_bank core/icici_bank core/kotak_bank)
  end
end