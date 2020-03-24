class Menu::Item

  attr_accessor :key, :id, :path, :icon, :label, :create, :features, :user_subscriptions, :permissions, :parent

  def initialize(params = {}, &block)
    params.each_pair do |attr, value|
      self.send("#{attr}=", value)
    end

    init

    instance_eval &block if block_given?
  end

  def items
    @items ||= []
  end

  def item(key, path: nil, icon: nil, label: nil, create: false, permissions: nil, features: nil, user_subscriptions: nil, &block)
    items << Menu::Item.new(key: key, path: path, icon: icon, label: label, create: create, permissions: permissions, features: features, user_subscriptions: user_subscriptions, &block)
  end

  def init
    self.id = key
    self.path ||= key
    self.label ||= path.to_s.titleize
    self.create ||= false
    self.permissions = [self.permissions] if self.permissions and not self.permissions.respond_to?(:each)
    self.features = [self.features] if self.features and not self.features.respond_to?(:each)

    init_parent
    # self.icon ||= "" todo add default icon
  end

  def init_parent
    return unless parent.present?

    self.id = "#{parent&.id}_#{key}"
  end

  def as_json(options = {})
    return unless authorized?(options)

    json = {
        id: id,
        path: path,
        icon: icon,
        label: label,
        create: create,
    }

    # Rejecting nil items as it would indicate that the tab should not be shown
    json[:items] = items.as_json(options).reject { |item| item.nil? } if items.present?
    json
  end

  def authorized?(options = {})
    current_user = options[:current_user]
    return false unless current_user.present?
    return false unless has_permission?(current_user)
    return false unless company_subscribed?(current_user)
    return false unless user_subscribed?(current_user)

    true
  end

  def has_permission?(user)
    return true if permissions.blank?
    return true if user.admin?
    return true if user.has_roles?(permissions)

    false
  end

  def company_subscribed?(user)
    return true unless features.present?

    features.each do |feature|
      return false unless !!user.company.feature_subscription.send(feature)
    end

    true
  end

  def user_subscribed?(user)
    return true unless user_subscriptions.present?

    user_subscriptions.each do |subscription|
      return false unless !!user.user_panel_subscription.send(subscription)
    end

    true
  end

end