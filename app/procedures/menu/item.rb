class Menu::Item
  include ActionManager::DSL

  attr_accessor :key, :id, :path, :icon, :label, :create, :features, :user_subscriptions, :permissions, :parent

  def initialize(params = {}, &block)
    params.except(:scopes).each_pair do |attr, value|
      self.send("#{attr}=", value)
    end

    init
    init_parent
    init_scopes(params[:scopes])

    instance_eval &block if block_given?
  end

  def items
    @items ||= []
  end

  def item(key, path: nil, icon: nil, label: nil, permissions: [], features: [], &block)
    items << Menu::Item.new(
        key: key, path: path, icon: icon, label: label,
        permissions: permissions, features: features, scopes: scopes, &block
    )
  end

  def scopes
    @scopes ||= []
  end

  def scope(path: nil, permissions: [], features: nil, &block)
    scopes.push({path: path, permissions: permissions, features: features})
    instance_eval &block
    scopes.pop
  end

  def init
    self.id = key
    self.path ||= key
    self.label ||= key.to_s.titleize

    if self.permissions and not self.permissions.respond_to?(:each)
      self.permissions = [self.permissions]
    else
      self.permissions = []
    end

    if self.features and not self.features.respond_to?(:each)
      self.features = [self.features]
    else
      self.features = []
    end

    init_parent
    add_id_to_path
    # self.icon ||= "" todo add default icon
  end

  def init_parent
    return unless parent.present?

    self.id = "#{parent&.id}_#{key}"
  end

  def init_scopes(scopes)
    scopes.each do |scope|
      self.path ||= scope[:path]

      if scope[:permissions].present?
        scope[:permissions] = [scope[:permissions]] unless scope[:permissions].respond_to?(:each)
        self.permissions += scope[:permissions]
      end

      if scope[:features].present?
        scope[:features] = [scope[:features]] unless scope[:features].respond_to?(:each)
        self.features += scope[:features]
      end
    end
  end

  def add_id_to_path
    path, params = self.path.to_s.split("/params=")
    params = params.present? ? JSON.parse(params) : {}
    params[:id] = self.id
    self.path = "#{path}/params=#{params.to_json}"
  end

  def as_json(options = {})
    return unless authorized?(options)

    json = {
        id: id,
        path: path,
        icon: icon,
        label: label,
    }

    # Rejecting nil items as it would indicate that the tab should not be shown
    if items.present?
      json[:items] = items.as_json(options).reject { |item| item.nil? }
    elsif actions.present?
      json[:items] = actions.values.as_json(options).reject { |item| item.nil? } if actions.present?
    end
    json
  end

  def authorized?(options = {})
    current_user = options[:current_user]
    return false unless current_user.present?
    return false unless current_user.has_permission?(permissions)
    return false unless company_subscribed?(current_user)
    return false unless user_subscribed?(current_user)

    true
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