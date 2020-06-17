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
        config: build_config(options),
    }
    if actions.present?
      map[:actions] = []
      actions.each_pair do |id, action|
        action = action.build(options)
        next if action.blank?

        map[:actions] << action
      end
    end
    map
  end

  def build_config(options)
    config
  end

  def as_json(options)
    build(options)
  end

end