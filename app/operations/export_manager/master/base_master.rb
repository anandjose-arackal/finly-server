class ExportManager::Master::BaseMaster
  include EventBus::Bus

  subscribers_path "#{Rails.root}/app/operations/export_manager/master"
end