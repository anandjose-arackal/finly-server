module ActionManager::DSL
  # extend ActiveSupport::Concern

  # class_methods do
    def actions
      @actions ||= {}
    end

    def action(type, id, config={}, &block)
      raise "Invalid action #{type}" unless ActionManager::Type[type].present?

      parent = self.class <= ActionManager::Action ? self : nil
      actions[id] = ActionManager::Type[type].new(type, id, config: config, action_scopes: action_scopes, action_registry: action_registry, parent: parent, &block)
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
      @action_paths ||= {}.with_indifferent_access
    end

    def register_action(path, action)
      action_paths[path] = action
    end

    def action_registry
      self
    end

  # end

end