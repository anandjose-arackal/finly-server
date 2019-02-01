# puts "connecting"
if Rails.env.production?
  Resque.redis = Redis.new({url: 'redis://172.33.155.100:6379/12', password: '6*JR*nzgYgd*OStzdz!u'})
else
  Resque.redis = Redis.new(url: 'redis://localhost:6379')
end