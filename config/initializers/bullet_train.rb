config = Rails.application.config_for(:feature_flipper)
if config.dig('api_key').present? and config.dig('url').present?
  BULLET_TRAIN = BulletTrain.new(api_key: config['api_key'], url: config['url'])
end