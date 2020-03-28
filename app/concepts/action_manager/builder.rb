module ActionManager::Builder
  extend ActiveSupport::Concern

  def build(user, params)
    return unless has_permission?(user)

    {
        label: self.label,
        icon: self.icon,
        type: self.type,
        config: build_config(user, params)
    }
  end

  def build_config(user, params)
    config
  end

  def has_permission?(user)
    return true if permissions.blank?
    return true if permissions.include?(:admin) and user.admin?(RequestStoreUtil.current_app)
    return true if user.has_roles?(permissions)

    false
  end

end