Dir.glob(Rails.root.join('app/models/form_entity**/*.rb')).each {|f| require(f)}
class Forms::API
  include DynamicAttributes

  class_attr :form_key
  class_attr :sections, default: []
  class_attr :conditions, default: {}
  class_attr :validations, default: {}
  class_attr :dependencies, default: {}
  class_attr :model

  def self.form
    @form ||= ActsAsTenant.without_tenant do
      Form.new(klass_name: self, model: self.model)
    end
  end

  def self.section(section_id, options = {}, &block)
    section = ActsAsTenant.without_tenant do
      form.sections.new({section_id: section_id}.merge(options))
    end
    section.instance_eval &block
  end

  def self.condition(params = {}, &block)
    return unless ActiveRecord::Base.connection.table_exists?('form_conditions')

    condition = FormCondition.system_condition(params, &block)
    if conditions[condition.condition_id].present?
      raise "Validation #{condition.condition_id} is not unique"
    end
    conditions[condition.condition_id] = condition
    ActsAsTenant.without_tenant do
      form.conditions << condition
    end
  end

  def self.validation(params = {}, &block)
    return unless ActiveRecord::Base.connection.table_exists?('form_entity_validations')

    validation = FormEntityValidation.system_validation(params, &block)
    if validations[validation.validation_id].present?
      raise "Validation #{validation.validation_id} is not unique"
    end
    validations[validation.validation_id] = validation
    ActsAsTenant.without_tenant do
      form.validations << validation
    end
  end
  singleton_class.send(:alias_method, :validate, :validation)

  def self.choice_dependency(params = {}, &block)
    return unless ActiveRecord::Base.connection.table_exists?('form_choice_dependencies')

    # dependency = Forms::API::ChoiceDependency.new(params, &block)
    dependency = FormChoiceDependency.system_dependency(params, &block)
    if dependencies[dependency.dependency_id].present?
      raise "Dependency #{dependency.dependency_id} is not unique"
    end
    dependencies[dependency.dependency_id] = dependency
    ActsAsTenant.without_tenant do
      form.choice_dependencies << dependency
    end
  end

  # def self.find_entity(entity_path)
  #   sections.each do |section|
  #     entity = section.find_entity entity_path
  #     return entity if entity
  #   end
  #   nil
  # end
  #
  # def self.fetch(user)
  #   ::Form.find_by(company_id: user.company_id, klass_name: self.name)
  # end

end