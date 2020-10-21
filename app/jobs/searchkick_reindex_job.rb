class SearchkickReindexJob
  include Sidekiq::Worker
  sidekiq_options queue: :payments_creation

  def self.logger
    @logger ||= LogStashLogger.new(type: :file, path: 'log/searchkick.log', sync: true)
  end

  # Reindex queued items
  def self.perform
    Searchkick.models.each do |model|
      Searchkick::ProcessQueueJob.new.perform(class_name: model.name, inline: true)
    end

    true
  end

  # Reindex all models
  def self.reindex(async: true)
    Searchkick.models.each do |model|
      if async
        perform_async(model.name)
      else
        new.perform(model.name)
      end
    end

    true
  end

  def perform(model_name)
    model = Object.const_get(model_name)
    start_time = Time.now
    model.reindex
    time = (Time.now - start_time).to_f
    self.class.logger.info({duration: time, reindexed_model: model.name})
  end

end