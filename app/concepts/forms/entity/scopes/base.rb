class Forms::Entity::Scopes::Base
  include DynamicAttributes

  class_attr :type
  attr_accessor :form_entity, :scope

  def self.register!(type)
    Forms::Entity::Scope.register(type, self)

    type(type)
  end

  def type
    self.class.type
  end

  def initialize(scope, form_entity: nil)
    self.scope = scope
    self.form_entity = form_entity
  end

  def find(choice, user: nil)
    raise "Find is not defined for #{klass}"
  end

  def valid?(choice, user: nil)
    raise "Valid is not defined for #{klass}"
  end

  def as_json(options = {})
    raise "Entity Scope is not defined for #{klass}"
  end

end