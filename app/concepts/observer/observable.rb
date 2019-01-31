module Observer::Observable

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def observer_map
      OBSERVERS[self.name] = {} if OBSERVERS[self.name].nil?
      OBSERVERS[self.name]
    end

    def observer_keys(*keys)
      keys.each {|key| ensure_method_defined key}
    end

    def register_master(klass)
      register :master, klass
      klass.add_observer(self)
    end

    def master
      observer_map[:master]
    end

    # Allow set a single value against a key
    def register(key, value)
      observer_map[key] = value

      ensure_method_defined key
    end

    # Allow setting multiple values against the key. This makes the return value of the key as an array
    def register_multiple(key, value)
      observer_map[key] = [] unless observer_map[key]&.respond_to?(:each)
      observer_map[key] << value

      ensure_method_defined key
    end

    def ensure_method_defined(key)
      return if methods.include?(key)

      define_singleton_method key do
        observer_map[key]
      end
    end

  end

end