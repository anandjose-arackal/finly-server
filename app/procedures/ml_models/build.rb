class MlModels::Build

  def self.perform
    MlModel::Monitor.build
    MlModel::FormEntityModel.build
  end

end