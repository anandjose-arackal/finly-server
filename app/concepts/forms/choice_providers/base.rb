class Forms::ChoiceProviders::Base
  include DynamicAttributes

  class_attr :type
  attr_accessor :form_entity, :config

  def self.register!(type)
    Forms::ChoiceProvider.register(type, self)

    type(type)
  end

  def self.config(*args)
    raise "config is not defined for #{self.name}"
  end

  def type
    self.class.type
  end

  def initialize(config, form_entity)
    self.config = config
    self.form_entity = form_entity
  end

  def find_by_id(id, params: {}, user: nil)
    raise "Find is not defined for #{klass}"
  end

  def find_by_name(name, params: {}, user: nil)
    raise "Find is not defined for #{klass}"
  end

  def choices(params, user:)
    raise "Choices is not defined for #{klass}"
  end

  def valid?(id: nil, name: nil, user: nil)
    if id
      find_by_id(id, user: user).present?
    elsif name
      find_by_name(name, user: user).present?
    end
  end

  def as_json(options = {})
    scope
  end

end