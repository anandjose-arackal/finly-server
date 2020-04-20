class ActionManager::Actions::ButtonGroup < ActionManager::Action

  register :button_group
  config :contextual

  def build(options)
    map = super(options)
    return unless map[:actions].present?

    map
  end

end