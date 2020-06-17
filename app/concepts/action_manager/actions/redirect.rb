class ActionManager::Actions::Redirect < ActionManager::Action

  config :contextual
  config :url
  register :redirect

end