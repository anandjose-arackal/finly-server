class EventManager::Workflows::Contract < Transactions::Contract
  include EventManager::Actions::FileManager::Validations

  class EventManager::Workflows::Contract::GroupSchema < Transactions::Schema

    params do
      required(:logic_type).filled(inclusion?: %w(group))
      required(:logic_operator).filled(inclusion?: %w(AND OR))
      required(:rules)
    end

  end

  class EventManager::Workflows::Contract::ConditionSchema < Transactions::Schema
    # %w(cont_any not_cont_any in not_in blank present lteq gteq is_in_the_range
    # lteq_days gteq_days eq_days is_in_days eq_days gteq lteq is_in_the_range)
    params do
      required(:logic_type).filled(inclusion?: %w(condition))
      required(:operator).filled
      required(:values).filled
    end
  end

  def self.group_schema
    @group_schema ||= EventManager::Workflows::Contract::GroupSchema.new
  end

  def self.condition_schema
    @condition_schema ||= EventManager::Workflows::Contract::ConditionSchema.new
  end

  property :name, validates: {presence: true}
  property :description, validates: {presence: true}
  property :model_class, validates: {presence: true, inclusion: {in: Documents::Master.list}}
  property :personal, default: false
  property :user_id, validates: {presence: true}
  property :company_id, validates: {presence: true}
  property :conditions
  collection :file_manager_actions, populate_if_empty: EventFileManagerAction do
    property :export_template_id, validates: {presence: true}
  end

  validate :atleast_one_action
  validate :conditions_schema_validation

  def conditions_schema_validation
    errors = check_group_schema(self.conditions)
    add_schema_errors errors if errors
  end

  def check_group_schema(params)
    schema = self.class.group_schema
    result = schema.call(params)
    return result.errors.to_h unless result.success?

    has_errors = false
    errors = {rules: {}}
    result[:rules].each_with_index do |rule, index|
      type = rule[:logic_type]
      case type
      when 'group'
        e = check_group_schema(rule)
      when 'condition'
        e = check_condition_schema(rule)
      else
        e = {rule: 'is invalid'}
      end
      if e.present?
        errors[:rules][index] = e
        has_errors = true
      end
    end
    has_errors ? errors : nil
  end

  def check_condition_schema(params)
    result = self.class.condition_schema.call(params)
    return result.errors.to_h unless result.success?

    nil
  end

  def atleast_one_action
    if file_manager_actions.blank?
      errors.add :action, 'is not defined'
      return
    end
  end
end