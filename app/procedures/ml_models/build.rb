class MlModels::Build

  def self.perform
    MlModel.all.each do |model|
      model.build_model
    end
  end

end