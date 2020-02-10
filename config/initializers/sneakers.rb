if Rails.env.production? and File.exists?("#{Rails.root}/config/bunny.yml")
  bunny_config = Rails.application.config_for(:bunny)&.with_indifferent_access
  MQ_PUBLISHER = Bunny.new(bunny_config)
  Sneakers.configure :connection => MQ_PUBLISHER,
                     :start_worker_delay => 0.2, # When workers do frenzy-die, randomize to avoid resource starvation
                     :workers => 4 # Number of per-cpu processes to run
else
  MQ_PUBLISHER = Bunny.new
  Sneakers.configure :connection => MQ_PUBLISHER,
                     :start_worker_delay => 0.2, # When workers do frenzy-die, randomize to avoid resource starvation
                     :workers => 4 # Number of per-cpu processes to run
end
