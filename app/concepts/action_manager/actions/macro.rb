class ActionManager::Actions::Macro < ActionManager::Action

  config :route
  register :macro

  def build_config(options)
    user = options[:current_user]
    ExportManager::Master.fetch(user, {screen: route})
  end

end