module ActionManager::Builder
  extend ActiveSupport::Concern

  def build(options)
    user = options[:current_user]
    params = options[:params]
    return unless permitted?(user)

    map = {
        path: self.path,
        label: self.label,
        icon: self.icon,
        type: self.type,
        format: self.format,
        config: build_config(user, params),
    }
    if actions.present?
      map[:actions] = []
      actions.each_pair do |id, action|
        action = action.build(user, params)
        next if action.blank?

        map[:actions] << action
      end
    end
    map
  end

  def build_config(user, params)
    config
  end

  def as_json(options)
    build(options)
  end

end