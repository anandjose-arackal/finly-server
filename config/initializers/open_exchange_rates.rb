require 'yaml'

unless File.exists?("#{Rails.root}/config/open_exchange_rates.yml")
  raise 'config/open_exchange_rates.yml not found'
end

OPEN_EXCHANGE_RATES = YAML.load_file("#{Rails.root}/config/open_exchange_rates.yml")
# BBPS_ERROR_MESSAGES = YAML.load_file(File.expand_path("config/bbps_error.yml"))