class MlModels::Track

  def self.perform
    MlModel.all.each do |model|
      model.track_predictions
    end
  end

end