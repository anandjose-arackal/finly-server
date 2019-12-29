module ExportManager::DSL::Config
  extend ActiveSupport::Concern

  included do
    class_attr :configurable, default: false
    class_attr :handle_name
    class_attr :label
    class_attr :screen
    class_attr :type, default: :generic
  end

  class_methods do
    def properties
      props = {
          label: label,
          type: type,
          handle: handle_name,
          screen: screen,
          configurable: configurable,
      }
      props[:config] = config if configurable
    end

    def config
      nil
    end

    def handle(event)
      handle_name(event)
      subscribe(event)
    end
  end

end