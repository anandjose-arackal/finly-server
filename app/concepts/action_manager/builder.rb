module ActionManager::Builder
  extend ActiveSupport::Concern

  def build(user, params)
    has_permission?(user)

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
    return true if user.has_roles?(permissions)

    false
  end

end