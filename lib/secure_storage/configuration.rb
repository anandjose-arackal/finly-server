# Implementation based on : https://www.viget.com/articles/easy-gem-configuration-variables-with-defaults/
module SecureStorage
  class Configuration

    def self.configuration
      yield self
    end

    def self.define_setting(name, default = nil)
      class_variable_set("@@#{name}", default)

      define_class_method "#{name}=" do |value|
        class_variable_set("@@#{name}", value)
      end

      define_class_method name do
        class_variable_get("@@#{name}")
      end
    end

    private

    def self.define_class_method(name, &block)
      (
      class << self;
        self;
      end).instance_eval do
        define_method name, &block
      end
    end

  end
end