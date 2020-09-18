require 'yaml'
require 'money'
require 'money/bank/open_exchange_rates_bank'


unless File.exists?("#{Rails.root}/config/open_exchange_rates.yml")
  raise 'config/open_exchange_rates.yml not found'
end

OPEN_EXCHANGE_RATES = YAML.load_file("#{Rails.root}/config/open_exchange_rates.yml")

LATEST_EXCHANGE_RATES = Money::Bank::OpenExchangeRatesBank.new
LATEST_EXCHANGE_RATES.app_id = OPEN_EXCHANGE_RATES['api_id']
LATEST_EXCHANGE_RATES.cache = 'lastest_exchange_rates_cache.json'
LATEST_EXCHANGE_RATES.ttl_in_seconds = 3600
