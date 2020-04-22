module ExportManager::DSL::Config
  extend ActiveSupport::Concern

  included do
    class_attr :configurable, default: false
    class_attr :handle_name
    class_attr :label
    class_attr :screen
    class_attr :system
    class_attr :type, default: :generic
    class_attr :resolver # Automatically generates the input using resolver if this is defined
    class_attr :description
    class_attr :company_scope, default: {}.with_indifferent_access
  end

  class_methods do
    def config
      {
          label: label,
          type: type,
          description: description,
          handle: handle_name,
          configurable: configurable,
      }
    end

    def handle(event)
      handle_name(event)
      subscribe(event)
    end

    def accept?(user, params)
      true
    end

    def scope(env, id, name)
      self.company_scope[env] = {id: id, name: name}
    end
  end

end