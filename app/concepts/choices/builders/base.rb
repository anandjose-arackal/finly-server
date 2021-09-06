class Choices::Builders::Base
  include DynamicAttributes

  class_attr :type
  attr_accessor :config, :entity

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

  def initialize(config, entity: nil)
    self.config = config
    self.entity = entity
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

end