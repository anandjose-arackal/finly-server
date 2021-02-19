class ActionManager::API < Transactions::API
  include DynamicAttributes
  extend ActionManager::DSL

  class_attr :registered_type

  singleton_class.send(:alias_method, :scope, :action_scope)
  singleton_class.send(:alias_method, :paths, :action_paths)

  user_model [User, AdminUser]

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

  def build(context, options)
    context[:config] = []
    context[:row_config] = []
    self.class.actions.each_pair do |id, action|
      hash = action.build(options)
      next if hash.nil?
      if action.row
        context[:row_config] << hash
      else
        context[:config] << hash
      end
    end
    context
  end

end