module Choices
  class Builder
    def self.serialize(klass, config)
      {type: klass.type, config: config}
    end

    def self.deserialize(config)
      handler(config[:type]).new(config[:config])
    end

    def self.choice_handlers
      @choice_handlers ||= {}.with_indifferent_access
    end

    def self.register(type, klass)
      choice_handlers[type] = klass
    end

    def self.handler(type)
      choice_handlers[type]
    end

    def self.[](key)
      choice_handlers[key]
    end
  end

end