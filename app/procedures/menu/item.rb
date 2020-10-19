class Menu::Item
  include ActionManager::DSL

  attr_accessor :key, :id, :path, :icon, :label, :create, :features, :user_subscriptions, :permissions, :parent, :toggle, :action_registry, :options

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

  def item(key, path: nil, icon: nil, label: nil, permissions: [], features: [], options: {}, &block)
    items << Menu::Item.new(
        key: key, path: path, icon: icon, label: label,
        action_registry: action_registry,
        permissions: permissions, features: features, scopes: scopes, options: options, &block
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
    self.path ||= key unless do_not_build_path?
    self.label ||= key.to_s.titleize

    if self.permissions and not self.permissions.respond_to?(:each)
      self.permissions = [self.permissions]
    elsif self.permissions.nil?
      self.permissions = []
    end

    self.features ||= []
    unless self.features.respond_to?(:each)
      self.features = [self.features]
    end

    init_parent
    add_id_to_path unless do_not_build_path?
    # self.icon ||= "" todo add default icon
  end

  def init_parent
    return unless parent.present?

    self.id = "#{parent&.id}_#{key}"
  end

  def do_not_build_path?
    self.options[:do_not_build_path]
  end

  def init_scopes(scopes)
    scopes.each do |scope|
      self.path ||= scope[:path] unless do_not_build_path?

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
        icon: icon,
        label: label,
    }
    # Since path is not used by all items
    json[:path] = path if path.present?

    # Rejecting nil items as it would indicate that the tab should not be shown
    if items.present?
      json[:items] = items.as_json(options).reject { |item| item.nil? }
      json[:items] = json[:items]&.map {|item| {item_type: 'menu'}.merge(item)}
      return nil if json[:items].blank?
    elsif actions.present?
      json[:items] = actions.values.as_json(options).reject { |item| item.nil? }
      json[:items] = json[:items]&.map {|item| {item_type: 'action'}.merge(item)}
      return nil if json[:items].blank?
    end
    json
  end

  def authorized?(options = {})
    current_user = options[:current_user]
    return false unless current_user.present?
    return false unless current_user.has_permission?(permissions)
    if toggle.present?
      klass = toggle.first
      method = toggle.second
      raise "Invalid toggle for menu item #{key}" if klass.blank? or method.blank?

      toggle = klass.new(current_user)
      raise "Invalid toggle for menu item #{key}, method #{method} is not found in klass #{klass}" unless toggle.respond_to?(method)

      return false unless toggle.send(method)
    end
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