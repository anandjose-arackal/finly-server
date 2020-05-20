class Choices::Builders::Base
  include DynamicAttributes

  class_attr :type
  attr_accessor :config, :form_entity

  def self.register!(type)
    Choices::Builder.register(type, self)

    type(type)
  end

  def self.call(*args)
    self.new(*args)
  end

  def type
    self.class.type
  end

  def initialize(config, form_entity: nil)
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

  def build(params: {}, user: {})
    raise "JSON is not defined for #{self.name}"
  end

  def as_json(options = {})
    Choices::Builder.serialize self, config
  end

  protected
  # Cache used to prevent database queries for fetching the same record in find_by_id or find_by_name
  # This is helpful while building contracts for forms entity lookup and for validating selected choices
  def finder_cache
    return nil unless form_entity.present?

    RequestStore[:contract_finder_cache] ||= {}.with_indifferent_access
    RequestStore[:contract_finder_cache][form_entity.id] ||= {name: {}, id: {}}
  end

end