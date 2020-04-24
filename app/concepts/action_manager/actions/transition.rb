class ActionManager::Actions::Transition < ActionManager::Action

  config :contextual
  config :url
  config :otp, default: false
  config :password, default: false

  register :transition

end