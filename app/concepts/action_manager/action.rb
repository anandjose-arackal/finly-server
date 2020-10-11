class ActionManager::Action
  include ActionManager::Type
  include ActionManager::Builder
  include ActionManager::DSL
  include DynamicAttributes

  attr_accessor :type, :id, :path, :parent, :action_registry, :action_scopes,
                :permissions, :label, :icon, :policy, :authorize, :features,
                :model, :format, :action_condition

  class_attribute :registered_type


  alias_method :scope, :action_scope
  alias_method :paths, :action_paths

  # Todo type specific validations
  # Todo merging scopes

  def self.config(param = nil, default: nil, &block)
    @config ||= []
    return @config if param.nil?

    @config << param unless @config.include?(param)
    unless block_given?
      block = lambda do |value|
        @config ||= {}
        @config[param] = value
        @config[param]
      end
    end
    define_method "#{param}=", &block
    define_method param do
      @config[param] ||= default
    end
  end

  def initialize(type, id, config: {}, action_scopes: [], parent: nil, action_registry: nil, &block)
    self.id = id
    self.type = type
    self.action_scopes = action_scopes.dup
    self.parent = parent
    self.action_registry = action_registry
    self.path = self.parent.present? ? "#{self.parent.path}/#{id}" : id.to_s

    # If a registry is provider, it registers itself as an action. This registration can be used for validation etc
    # Not mandating it help decouple the action to be used independently
    self.action_registry&.register_action(path, self)

    action_scopes.each do |conf|
      conf.each_pair do |key, value|
        self.send("#{key}=", value)
      end
    end

    config.each_pair do |key, value|
      self.send("#{key}=", value)
    end

    init

    instance_eval &block if block_given?
  end

  def init

  end

  def config
    conf = {}
    self.class.config.each do |key|
      conf[key] = self.send(key)
    end
    conf
  end

  def permissions=(value)
    return if value.blank?
    value = [value] unless value.respond_to?(:each)

    @permissions ||= []
    @permissions += value
    @permissions.uniq!
    @permissions
  end

  def format
    @format || 'standard'
  end

  # def action_registry
  #   @action_registry
  # end

  def permitted?(user)
    return false unless feature_subscribed?(user)
    return false unless user.has_permission?(permissions)

    true
  end

  def feature_subscribed?(user)
    return true if features.blank?

    self.features ||= []
    self.features = [self.features] unless self.features.respond_to?(:each)
    self.features.each do |feature|
      return false unless !!user.company.feature_subscription.send(feature)
    end

    true
  end

  def authorized?(context)
    return false unless permitted?(context[:current_user])
    return true unless authorize.present?
    raise "Policy has not been defined for the action #{self.id}" unless policy.present?

    authorize = {if: authorize} if authorize.is_a?(Symbol) or authorize.is_a?(String)
    raise "Invalid authorization for the action #{self.id}" if authorize[:if].blank? and authorize[:unless].blank?

    policy = self.policy.new(context[:current_user], context[:record])

    return false if authorize[:if].present? and not policy.send(authorize)
    return false if authorize[:unless].present? and policy.send(authorize)
    return false if action_condition.present? and not Transactions::Evaluator.eval(action_registry, action_condition, context)

    true
  end

  # def actions
  #   @actions ||= {}
  # end
  #
  # def action(type, id, config = {}, &block)
  #   actions[id] = ActionManager::Type[type].new(type, id, config: config, scopes: scopes, parent: self, registry: registry, &block)
  # end
  #
  # def scopes
  #   @scopes ||= []
  # end
  #
  # def scope(params = {}, &block)
  #   scopes.push(params)
  #   instance_eval &block
  #   scopes.pop
  # end

end