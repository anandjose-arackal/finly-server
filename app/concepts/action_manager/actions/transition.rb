class ActionManager::Actions::Transition < ActionManager::Action

  config :url
  config :otp, default: false
  config :password, default: false

  register :transition

end