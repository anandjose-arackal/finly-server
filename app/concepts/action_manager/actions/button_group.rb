class ActionManager::Actions::ButtonGroup < ActionManager::Action

  register :button_group
  config :contextual

  def build(user, params)
    map = super(user, params)
    return unless map[:actions].present?

    map
  end

end