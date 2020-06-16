module ActionManager::Type
  extend ActiveSupport::Concern

  def self.[](type)
    types[type]
  end

  def self.types
    @types ||= {}.with_indifferent_access
  end

  class_methods do
    def register(type)
      self.registered_type = type
      ActionManager::Type.types[type] = self

      ActionManager::Type.module_eval do
        define_method type do |args, &block|
          action type, name, args, &block
        end
      end
    end
  end

end