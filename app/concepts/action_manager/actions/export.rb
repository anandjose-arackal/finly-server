class ActionManager::Actions::Export < ActionManager::Action

  config :route
  register :export

  def build_config(options)
    user = options[:current_user]
    ExportManager::Master.fetch(user, {screen: route})
  end

end