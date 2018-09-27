# puts "connecting"
# if Rails.env.production?
#   uri = URI.parse('redis://172.33.155.100:6379/12')
#   Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => '6*JR*nzgYgd*OStzdz!u', db: 12, :thread_safe => true)
# end