HealthMonitor.configure do |config|
  #config.database -> Considered default. Not required
  # config.cache
  config.sidekiq.configure do |sidekiq_config|
    sidekiq_config.latency = 3.hours
    sidekiq_config.queue_size = 50
  end
  # config.redis.configure do |redis_config|
  #   # redis_config.connection = Redis.current # use your custom redis connection
  #   # redis_config.url = 'redis://user:pass@example.redis.com:90210/' # or URL
  #   # redis_config.max_used_memory = 200 # Megabytes
  # end
end