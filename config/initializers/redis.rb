if File.exists?("#{Rails.root}/config/redis_config.yml")
  redis_config = Rails.application.config_for(:redis_config)
  REDIS = Redis.new redis_config
else
  REDIS = Redis.new
end