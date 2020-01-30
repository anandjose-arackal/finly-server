class Forms::Contracts::Transformers::Base

  attr_accessor :name, :value, :entity

  def setters
    @setters ||= []
  end

  def validates
    @validates ||= []
  end

  def validate
    @validate ||= []
  end

  def initialize(entity, name, value)
    self.entity = entity
    self.name = name
    self.value = value
    transform!
  end

  def transform!
    raise "To be implemented"
  end

  def self.register(key)
    Forms::Contracts::Transformers::Registry.register(key, self)
  end


end