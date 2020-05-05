class Forms::API
  include DynamicAttributes

  class_attr :sections, default: []
  class_attr :conditions, default: {}
  class_attr :validations, default: {}
  # class_attr :dependencies, default: []
  class_attr :model

  def self.section(name, options = {}, &block)
    sections << Forms::API::Entity::Section.new(self, name, options, &block)
  end

  def self.condition(params = {}, &block)
    condition = Forms::API::Condition.new(params, &block)
    if conditions[condition.id].present?
      raise "Validation #{condition.id} is not unique"
    end
    conditions[condition.id] = condition
  end

  def self.validation(params, &block)
    validation = Forms::API::Validation.new(params, &block)
    if validations[validation.id].present?
      raise "Validation #{validation.id} is not unique"
    end
    validations[validation.id] = validation
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