# puts "connecting"
if Rails.env.production?
  redis_config = Rails.application.config_for(:redis_config)
  Resque.redis = Redis.new({url: redis_config['url'], password: redis_config['password']})
else
  Resque.redis = Redis.new(url: 'redis://127.0.0.1:6379')
end