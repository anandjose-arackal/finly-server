if File.exists?("#{Rails.root}/config/bunny.yml")
  bunny_config = Rails.application.config_for(:bunny)&.with_indifferent_access
  MQ_PUBLISHER = Bunny.new(bunny_config)
  Sneakers.configure :connection => MQ_PUBLISHER#, workers: 1
end
