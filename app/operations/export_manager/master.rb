class ExportManager::Master
  include EventBus::Bus

  subscribers_path "#{Rails.root}/app/operations/export_manager/master"
end