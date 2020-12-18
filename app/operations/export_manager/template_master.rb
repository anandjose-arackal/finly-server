class ExportManager::TemplateMaster
  include EventBus::Bus

  subscribers_path "#{Rails.root}/app/operations/export_manager/template/master"

  def self.get_default_template(resource)
    return {} unless subscribers[resource].present?
    handlers = []
    subscribers[resource].each do |master|
      return master.build if master.default
    end
    {}
  end
end