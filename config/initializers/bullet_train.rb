config = Rails.application.config_for(:feature_flipper)
BULLET_TRAIN = BulletTrain.new(api_key: config['api_key'], url: config['url'])
