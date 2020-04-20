module ActionManager::DSL
  # extend ActiveSupport::Concern

  # class_methods do
    def actions
      @actions ||= {}
    end

    def action(type, id, config={}, &block)
      raise "Invalid action #{type}" unless ActionManager::Type[type].present?

      actions[id] = ActionManager::Type[type].new(type, id, config: config, scopes: action_scopes, registry: registry, &block)
    end

    def action_scopes
      @action_scopes ||= []
    end

    def action_scope(params={}, &block)
      action_scopes.push(params)
      instance_eval &block
      action_scopes.pop
    end

    # Path gives access to all nested actions as well. Easier to navigate to find the action instead of iterating through actions
    def action_paths
      @paths ||= {}.with_indifferent_access
    end

    def register_path(path, action)
      action_paths[path] = action
    end

    def registry
      self
    end
  # end

end