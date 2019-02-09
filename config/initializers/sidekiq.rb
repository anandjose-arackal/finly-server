if Rails.env.production?
  Sidekiq::Logstash.setup
  Sidekiq.configure_server do |config|
    config.redis = {url: 'redis://172.33.155.100:6379/12', password: '6*JR*nzgYgd*OStzdz!u'}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: 'redis://172.33.155.100:6379/12', password: '6*JR*nzgYgd*OStzdz!u'}
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