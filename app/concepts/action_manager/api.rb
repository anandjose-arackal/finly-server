class ActionManager::API < Transactions::API
  include DynamicAttributes

  class_attr :registered_type

  def self.actions
    @actions ||= {}
  end

  def self.action(type, id, config={}, &block)
    raise "Invalid action #{type}" unless ActionManager::Registry[type].present?

    actions[id] = ActionManager::Registry[type].new(type, id, config: config, scopes: scopes, root: self, &block)
  end

  def self.scopes
    @scopes ||= []
  end

  def self.scope(params={}, &block)
    scopes.push(params)
    instance_eval &block
    scopes.pop
  end

  # Path gives access to all nested actions as well. Easier to navigate to find the action instead of iterating through actions
  def self.paths
    @paths ||= {}.with_indifferent_access
  end

  def self.register_path(path, action)
    paths[path] = action
  end

  schema do
    params do
      required(:route).filled
    end
  end

  step :validate_route
  pass :build

  def validate_route(context, params:, **)
    unless ActionManager::Router.routes.include?(params[:route])
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