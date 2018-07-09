if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = {url: 'redis://172.32.19.108:6379/12', password: '6*JR*nzgYgd*OStzdz!u'}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: 'redis://172.32.19.108:6379/12', password: '6*JR*nzgYgd*OStzdz!u'}
  end
end