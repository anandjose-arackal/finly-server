module ExportManager::DSL::Config
  extend ActiveSupport::Concern

  included do
    class_attr :configurable, default: false
    class_attr :handle_name
    class_attr :label
    class_attr :screen
    class_attr :system
    class_attr :type, default: :generic
    class_attr :document
  end

  class_methods do
    def config
      {
          label: label,
          type: type,
          document: document,
          handle: handle_name,
          screen: screen,
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
  end

end