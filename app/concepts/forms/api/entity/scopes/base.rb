class Forms::API::Entity::Scopes::Base
  include DynamicAttributes

  class_attr :type
  attr_accessor :form_entity, :scope

  def self.register!(type)
    Forms::API::Entity::Scope.register(type, self)

    type(type)
  end

  def type
    self.class.type
  end

  def initialize(scope, form_entity)
    self.scope = scope
    self.form_entity = form_entity
  end

  def find_by_id(choice, user: nil)
    raise "Find is not defined for #{klass}"
  end

  def find_by_name(choice, user: nil)
    raise "Find is not defined for #{klass}"
  end

  def valid?(id: nil, name: nil, user: nil)
    if id
      find_by_id(id, user: user).present?
    elsif name
      find_by_name(name, user: user).present?
    end
  end

  def self.scope(*args)
    raise "scope is not defined for #{self.class}"
  end

  def as_json(options = {})
    scope
  end

end