class ActionManager::Actions::Transition < ActionManager::Action

  config :contextual
  config :url
  config :otp, default: false
  config :password, default: false
  config :record_scope

  register :transition

end