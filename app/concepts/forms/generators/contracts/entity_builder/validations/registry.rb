class Forms::Generators::Contracts::EntityBuilder::Validations::Registry

  def self.handlers
    @handlers ||= {}.with_indifferent_access
  end

  def self.register(key, klass)
    handlers[key] = klass
  end

  def self.for(key)
    handlers[key]
  end

end