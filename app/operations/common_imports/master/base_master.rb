class CommonImports::Master::BaseMaster
  include EventBus::Bus

  subscribers_path "#{Rails.root}/app/operations/common_imports/master"
end