class MlModels::Track
  sidekiq_options queue: :payments_creation

  def self.perform
    MlModel.all.each do |model|
      model.track_predictions
    end
  end

end