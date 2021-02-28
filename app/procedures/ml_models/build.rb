class MlModels::Build
  sidekiq_options queue: :payments_creation

  def self.perform
    MlModel.all.each do |model|
      model.build_model
    end
  end

end