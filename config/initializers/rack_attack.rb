redis_config = Rails.application.config_for(:redis_config)
redis_client = Redis.new({url: redis_config['url'], password: redis_config['password']})
Rack::Attack.cache.store = Rack::Attack::StoreProxy::RedisStoreProxy.new(redis_client)

unless Rails.env.production?
  Rack::Attack.safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip || '::1' == req.ip
  end
end

# Request Throttling Start
# 120rpm
# 500request per 5minutes
# 2000request per hour
# 15000request per day
Rack::Attack.throttle('Request/IP throttling - Minute', limit: 120, period: 1.minutes) do |req|
  req.ip
end

Rack::Attack.throttle('Request/IP throttling - 5 minutes', limit: 500, period: 5.minutes) do |req|
  req.ip
end

Rack::Attack.throttle('Request/IP throttling - 1 hour', limit: 2000, period: 1.hour) do |req|
  req.ip
end

Rack::Attack.throttle('Request/IP throttling - 1 day', limit: 15000, period: 1.day) do |req|
  req.ip
end
# Request Throttling End

# Public-Sensitive Throttling Start
# # Throttle Lookups
# # Throttle ForgotPassword
# # Throttle Send OTP
# # Throttle Login

# 3/6 seconds
# 20/1 minute
# 40/10 minutes
# 80/100 minutes
# 200/1000 minutes
{
    lookup: 'lookup',
    token: 'token',
    send_otp: 'send_verification_otp',
    verify_otp: 'verify_user_otp',
    set_password: 'users/password'
}.each do |key, pattern|
  Rack::Attack.throttle("#{key} throttling - 6 seconds", limit: 3, period: 6.seconds) do |req|
    req.ip if req.path.include?(pattern)
  end

  Rack::Attack.throttle("#{key} throttling - 1 minute", limit: 20, period: 1.minute) do |req|
    req.ip if req.path.include?(pattern)
  end

  Rack::Attack.throttle("#{key} throttling - 10 minute", limit: 40, period: 10.minute) do |req|
    req.ip if req.path.include?(pattern)
  end

  Rack::Attack.throttle("#{key} throttling - 100 minute", limit: 80, period: 100.minute) do |req|
    req.ip if req.path.include?(pattern)
  end

  Rack::Attack.throttle("#{key} throttling - 1000 minute", limit: 200, period: 1000.minute) do |req|
    req.ip if req.path.include?(pattern)
  end
end


# Public-Sensitive Throttling Start

# Safelist API requests from known providers
# Throttle Credit APIs -> Bulk + Individual + API
# Throttle Approve
# Block Request without UserAgent for web requests
#