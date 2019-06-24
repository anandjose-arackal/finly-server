if Rails.env.production?
  Sidekiq::Logstash.setup
  redis_config = Rails.application.config_for(:redis_config)
  Sidekiq.configure_server do |config|
    config.redis = {url: redis_config['url'], password: redis_config['password']}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: redis_config['url'], password: redis_config['password']}
  end
else
  Sidekiq.configure_server do |config|
    config.redis = {url: 'redis://127.0.0.1:6379'}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: 'redis://127.0.0.1:6379'}
  end
end


Sidekiq::Extensions.enable_delay!