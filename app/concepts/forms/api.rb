Dir.glob(Rails.root.join('app/models/form_entity**/*.rb')).each { |f| require(f) }

class Forms::API
  include DynamicAttributes

  class_attr :form_key
  class_attr :sections, default: []
  class_attr :conditions, default: {}
  class_attr :validations, default: {}
  class_attr :dependencies, default: {}
  class_attr :model
  class_attr :label
  class_attr :predictions, default: {}

  def self.form
    @form ||= ActsAsTenant.without_tenant do
      Form.new(klass_name: self, model: self.model, label: (self.label || self.model.name))
    end
  end

  def self.meta(form_meta = NoObject)
    @meta ||= form_meta unless form_meta == NoObject
    @meta
  end

  def self.section(section_id, options = {}, &block)
    section = ActsAsTenant.without_tenant do
      form.sections.new({ section_id: section_id }.merge(options))
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

  # This is used to define predictions for form entities
  #
  # @param entity_path Entity path of the target entity for which the prediction has to be made
  # @param with is used to define the dependent entities which is used for predicting the target entity
  # @param split_key represents the datetime object which is used for adding datetime parameter to the prediction. This defaults to submitted_at
  #
  # @example
  #   predict 'policy_id', with: ['vendor_id']
  #   predict 'items.inventory_item_id', with: ['vendor_id', 'policy_id'], split_key: "created_at"
  def self.predict(entity_path, with: [], split_key: NoObject)
    with = [with] if with.present? and not with.respond_to?(:each)

    if split_key == NoObject
      split_key = form.model.has_attribute?(:submitted_at) ? :submitted_at : :created_at
    end

    split_key_type = split_key.present? ? 'datetime' : nil

    prediction = MlModel::FormEntityModel.system_model(
      model_klass: form.model,
      form_entity_path: entity_path,
      dependent_entity_paths: with,
      attributes: {
        split_key: split_key,
        split_key_type: split_key_type
      }
    )

    raise "Prediction #{entity_path} is not unique" if predictions[entity_path].present?

    predictions[entity_path] = prediction
    form.prediction_models << prediction
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