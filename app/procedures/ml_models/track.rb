class MlModels::Track < BaseJob

  def self.perform_job
    MlModel.all.enabled.each do |model|
      model.track_predictions
    end
  end

end