class Forms::API
  include DynamicAttributes

  class_attr :sections, default: []
  class_attr :conditions, default: []
  class_attr :validations, default: []
  # class_attr :dependencies, default: []
  class_attr :model

  def self.section(name, options = {}, &block)
    sections << Forms::API::Entity::Section.new(self, name, options, &block)
  end

  def self.collection(name, options = {}, &block)
    sections << Forms::API::Entity::Section.new(self, name, {collection: true}.merge(options), &block)
  end

  # def self.dependency(map)
  #   dependencies << Forms::API::Dependency.new(map)
  # end

  def self.condition(type, &block)
    conditions << Form::API::Condition.new(type, &block)
  end

  def self.validation(entity_key, validation = nil, &block)
    validations << Form::API::Validation.new(entity_key, validation, &block)
  end
  singleton_class.send(:alias_method, :validate, :validation)

  # def validate(entity_key, validation = nil, &block)
  #   validation(entity_key, validation, block)
  # end

  def self.find_entity(field_path)
    sections.each do |section|
      entity = section.find_entity field_path
      return entity if entity
    end
    nil
  end

  def self.fetch(user)
    ::Form.find_by(company_id: user.company_id, klass_name: self.name)
  end

end