class ActionManager::Actions::Export < ActionManager::Action

  config :route
  register :export

  def build_config(user, params)
    ExportManager::Master.fetch(user, params)
  end

end