class MlModels::Build < BaseJob

  def self.perform_job
    MlModel::Monitor.build
    MlModel::FormEntityModel.build
  end

end