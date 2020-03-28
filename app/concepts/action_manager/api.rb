class ActionManager::API < Transactions::API
  include DynamicAttributes

  class_attr :registered_type

  def self.actions
    @actions ||= {}
  end

  def self.action(type, id, config={}, &block)
    raise "Invalid action #{type}" unless ActionManager::Registry[type].present?

    actions[id] = ActionManager::Registry[type].new(type, id, config: config, scopes: scopes, &block)
  end

  def self.scopes
    @scopes ||= []
  end

  def self.scope(params={}, &block)
    scopes.push(params)
    instance_eval &block
    scopes.pop
  end

  step :validate_route
  pass :build

  def validate_route(context, params:, **)
    unless params[:route].present? and ActionManager::Router.routes.include?(params[:route])
      return on_error context, :base, "Invalid route"
    end

    true
  end

  def build(context, params:, current_user:, **)
    context[:config] = []
    self.class.actions.each_pair do |id, action|
      hash = action.build(current_user, params)
      next if hash.nil?

      context[:config] << hash
    end
  end

end