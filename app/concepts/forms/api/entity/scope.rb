class Forms::API::Entity::Scope

  def self.scope_handlers
    @scope_handlers ||= {}.with_indifferent_access
  end

  def self.register(type, klass)
    scope_handlers[type] = klass
  end

  def self.handler(type)
    scope_handlers[type]
  end

  def self.[](key)
    scope_handlers[key]
  end

end