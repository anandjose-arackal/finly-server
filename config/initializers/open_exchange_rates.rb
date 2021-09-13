# require 'yaml'
# require 'money'
# require 'money/bank/open_exchange_rates_bank'


# unless File.exists?("#{Rails.root}/config/open_exchange_rates.yml")
#   raise 'config/open_exchange_rates.yml not found'
# end

# OPEN_EXCHANGE_RATES = YAML.load_file("#{Rails.root}/config/open_exchange_rates.yml")

# LATEST_EXCHANGE_RATES = Money::Bank::OpenExchangeRatesBank.new
# LATEST_EXCHANGE_RATES.app_id = OPEN_EXCHANGE_RATES['app_id']
# LATEST_EXCHANGE_RATES.ttl_in_seconds = 3600

# redis_config = Rails.application.config_for(:redis_config)&.with_indifferent_access
# redis_creds = redis_config&.slice('url', 'password')
# redis = Redis.new(redis_creds)
# OXR_CACHE_KEY = 'money:open_exchange_rates'.freeze

# LATEST_EXCHANGE_RATES.cache = Proc.new do |text|
#   if text
#     redis.set(OXR_CACHE_KEY, text)
#     redis.expire(OXR_CACHE_KEY, 3600)
#   else
#     redis.get(OXR_CACHE_KEY)
#   end
# end
# # LATEST_EXCHANGE_RATES.update_rates
