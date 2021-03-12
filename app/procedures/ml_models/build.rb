class MlModels::Build

  def self.perform
    MlModel.all.each do |model|
      model.build_model
      model.clear_model_cache
    end
  end

end