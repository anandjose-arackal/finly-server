module Observer::Observable

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    unless defined?(registered_keys)
      cattr_accessor :registered_keys
      self.registered_keys = {}
    end

    def register_master(klass)
      klass.add_observer(self)
    end

    # Allow set a single value against a key
    def register(key, value)
      registered_keys[key] = value

      ensure_method_defined key
    end

    # Allow setting multiple values against the key
    def register_multiple(key, value)
      unless registered_keys[key].respond_to(:each)
        registered_keys[key] = []
      end
      registered_keys[key] << value

      ensure_method_defined key
    end

    def ensure_method_defined(key)
      unless methods.include?(key)
        define_singleton_method key do
          registered_keys[key]
        end
      end
    end


  end

end