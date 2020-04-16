class ActionManager::Action
  include ActionManager::Registry
  include ActionManager::Builder
  include DynamicAttributes

  attr_accessor :type, :id, :path, :parent, :root, :scopes,
                :permissions, :label, :icon, :policy, :authorize,
                :actions, :model, :format

  class_attribute :registered_type

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

  def initialize(type, id, config: {}, scopes: [], parent: nil, root: nil, &block)
    self.id = id
    self.type = type
    self.scopes = scopes
    self.parent = parent
    self.root = root
    self.path = self.parent.present? ? "#{self.parent.path}/#{id}" : id

    self.root.register_path(path, self)

    scopes.each do |conf|
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

  def actions
    @actions ||= {}
  end

  def action(type, id, config = {}, &block)
    actions[id] = ActionManager::Registry[type].new(type, id, config: config, scopes: scopes, parent: self, root: root, &block)
  end

  def scopes
    @scopes ||= []
  end

  def scope(params = {}, &block)
    scopes.push(params)
    instance_eval &block
    scopes.pop
  end

end