class MlModels::Track < BaseJob

  def self.perform_job
    MlModel.all.each do |model|
      model.track_predictions
    end
  end

end