redis_config = Rails.application.config_for(:redis_config)
redis_client = Redis.connect({url: redis_config['url'], password: redis_config['password']})
Rack::Attack.cache.store = Rack::Attack::StoreProxy::RedisStoreProxy.new(redis_client)

Rack::Attack.blocklist_ip('192.168.1.215')
Rack::Attack.blocklist("test message") do |req|
  false
end

# Safelist API requests from known providers
# Throttle lookups
# Throttle forgot password
# Throttle send otp
# Throttle login
# Throttle Requests per minute, 1 hour, 8 hours, 24 hours
# Block Request without UserAgent for web requests
#