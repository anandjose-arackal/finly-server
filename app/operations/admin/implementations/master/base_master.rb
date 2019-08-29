class Admin::Implementations::Master::BaseMaster
  include EventBus::Bus

  subscribers_path "#{Rails.root}/app/operations/admin/implementations/master"
end