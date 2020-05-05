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

  def self.condition(&block)
    conditions << Forms::API::Condition.new(&block)
  end

  def self.validation(entity_path, &block)
    validations << Forms::API::Validation.new(entity_path, &block)
  end
  singleton_class.send(:alias_method, :validate, :validation)

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