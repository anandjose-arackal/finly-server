class MlModels::Track

  def self.perform
    MlModel.all.each do |model|
      model.track_predictions
      model.clear_model_cache
    end
  end

end