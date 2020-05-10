class Forms::API
  include DynamicAttributes

  class_attr :form_key
  class_attr :sections, default: []
  class_attr :conditions, default: {}
  class_attr :validations, default: {}
  class_attr :dependencies, default: {}
  class_attr :model

  def self.form
    @form ||= Form.new(klass_name: self, model: self.model)
  end

  def self.section(section_id, options = {}, &block)
    section = form.sections.new({section_id: section_id}.merge(options))
    section.instance_eval &block
  end

  def self.condition(params = {}, &block)
    return unless ActiveRecord::Base.connection.table_exists?('form_conditions')

    condition = FormCondition.system_condition(params, &block)
    if conditions[condition.condition_id].present?
      raise "Validation #{condition.condition_id} is not unique"
    end
    conditions[condition.condition_id] = condition
    form.conditions << condition
  end

  def self.validation(params, &block)
    return unless ActiveRecord::Base.connection.table_exists?('form_entity_validations')

    validation = FormEntityValidation.system_validation(params, &block)
    if validations[validation.validation_id].present?
      raise "Validation #{validation.validation_id} is not unique"
    end
    validations[validation.validation_id] = validation
    form.validations << validation
  end
  singleton_class.send(:alias_method, :validate, :validation)

  def self.choice_dependency(params, &block)
    return unless ActiveRecord::Base.connection.table_exists?('form_choice_dependencies')

    dependency = Forms::API::ChoiceDependency.new(params, &block)
    dependencies[dependency.dependency_id] = dependency
  end

  def self.find_entity(entity_path)
    sections.each do |section|
      entity = section.find_entity entity_path
      return entity if entity
    end
    nil
  end

  def self.fetch(user)
    ::Form.find_by(company_id: user.company_id, klass_name: self.name)
  end

end