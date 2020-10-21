redis_config = Rails.application.config_for(:redis_config)&.with_indifferent_access
Searchkick.redis = ConnectionPool.new { Redis.new(redis_config.slice('url', 'password')) }

searchkick_config = Rails.application.config_for(:searchkick)
if searchkick_config.present?
  ENV['ELASTICSEARCH_URL'] = searchkick_config[:elasticsearch_url]
  Searchkick.index_prefix = searchkick_config[:prefix]
end