redis_config = Rails.application.config_for(:redis_config)
redis_client = Redis.new({url: redis_config['url'], password: redis_config['password']})
rack_attack_logger = LogStashLogger.new(type: :file, path: 'log/rack_attack_block.log', sync: true)
Rack::Attack.cache.store = Rack::Attack::StoreProxy::RedisStoreProxy.new(redis_client)

# unless Rails.env.production?
#   Rack::Attack.safelist('allow from localhost') do |req|
#     # Requests are allowed if the return value is truthy
#     '127.0.0.1' == req.ip || '::1' == req.ip
#   end
# end

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

# Do not allow requests without any user agent
Rack::Attack.blocklist('Blocklist request without user agent') do |req|
  # `filter` returns truthy value if request fails, or if it's from a previously banned IP
  # so the request is blocked
  Rack::Attack::Fail2Ban.filter("no_user_agent-#{req.ip}", maxretry: 1, findtime: 10.minutes, bantime: 1.hour) do
    # The count for the IP is incremented if the return value is truthy
    req.ip unless req.user_agent
  end
end

ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, req|
  next unless [:throttle, :blocklist].include?(req.env["rack.attack.match_type"])

  request = {
      referrer: req.referer,
      ip: req.ip,
      user_agent: req.user_agent,
      langing_page: req.url,
      http_method: req.request_method,
      path: req.path,
      block_reason: req.env["rack.attack.match_type"],
      response_code: 429
  }
  RequestImpressions::OnRackAttackBlock.call_async(request, req.params)

  rack_attack_logger.info request.merge({params: req.params})
end


# Public-Sensitive Throttling Start

# Safelist API requests from known providers
# Throttle Credit APIs -> Bulk + Individual + API
# Throttle Approve
# Block Request without UserAgent for web requests
#