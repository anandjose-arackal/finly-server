# if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = {url: 'redis://master.finly-redis-prod-2.nrnep5.aps1.cache.amazonaws.com:6379/12', password: '6*JR*nzgYgd*OStzdz!u'}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: 'redis://master.finly-redis-prod-2.nrnep5.aps1.cache.amazonaws.com:6379/12', password: '6*JR*nzgYgd*OStzdz!u'}
  end
# end