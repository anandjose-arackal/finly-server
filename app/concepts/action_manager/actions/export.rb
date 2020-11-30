class ActionManager::Actions::Export < ActionManager::Action

  config :route
  config :contextual
  register :export

  def build_config(options)
    user = options[:current_user]
    old_exports = ExportManager::Master.fetch(user, {screen: route})

    new_exports = Masters::ExportTemplates::Ops::Index.({ current_user: user, params: {route: route} })['model.records'].map do |record|
      {
        template_export: true,
        name: record.name,
        id: record.id,
        export_format: record.export_format,
        description: record.description,
        resource: record.resource,
      }
    end

    if ExportManagerToggle.new(User.first).templates_enabled?
      old_exports = old_exports.filter do |record|
        !record[:has_template]
      end
      new_exports + old_exports
    else
      old_exports
    end
  end

end