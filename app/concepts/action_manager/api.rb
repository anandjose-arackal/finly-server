class ActionManager::API
  include DynamicAttributes

  class_attr :registered_type

  def self.actions
    @actions ||= []
  end

  def self.action(type, config={}, &block)
    raise "Invalid action #{type}" unless ActionManager::Registry[type].present?

    actions << ActionManager::Registry[type].new(type, config: config, scopes: scopes, &block)
  end

  def self.scopes
    @scopes ||= []
  end

  def self.scope(params={}, &block)
    scopes.push(params)
    instance_eval &block
    scopes.pop
  end

  def self.build(user, params)
    result = []
    actions.each do |action|
      hash = action.build(user, params)
      next if hash.nil?

      result << hash
    end
    result
  end

end