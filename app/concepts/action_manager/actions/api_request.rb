class ActionManager::Actions::ApiRequest < ActionManager::Action
  register :api_request

  config :contextual
  config :url
  config :method
  config :confirmation
  config :confirmation_message
  config :success_function
  config :failure_function
end