class SearchkickReindexJob
  include Sidekiq::Worker
  sidekiq_options queue: :payments_creation

  def self.logger
    @logger ||= LogStashLogger.new(type: :file, path: 'log/searchkick.log', sync: true)
  end

  # Reindex all models
  def self.run(async: true)
    run_async and return true if async

    run_sync

    true
  end

  def self.run_async
    Searchkick.models.each do |model|
      perform_async(model.name)
    end
  end

  def self.run_sync
    Searchkick.models.each do |model|
      new.perform(model.name)
    end
  end

  def perform(model_name)
    model = Object.const_get(model_name)
    start_time = Time.now
    model.reindex
    time = (Time.now - start_time).to_f
    self.class.logger.info({duration: time, reindexed_model: model.name})
  end

end