class EventManager::Workflows::Contract < Transactions::Contract
  include EventManager::Actions::FileManager::Validations

  property :name, validates: {presence: true}
  property :description, validates: {presence: true}
  property :model_class, validates: {presence: true, inclusion: {in: Documents::Master.list}}
  property :personal, default: false
  property :user_id, validates: {presence: true}
  property :company_id, validates: {presence: true}
  property :conditions #, form: EventManager::Workflows::Contract::ConditionsSchema
  collection :file_manager_actions, populate_if_empty: EventFileManagerAction do
    property :export_template_id, validates: {presence: true}
  end

  validate :atleast_one_action
  # validate :conditions_schema_validation

  def conditions_schema_validation
    # schema = EventManager::Workflows::Contract::GroupSchema.new
    # add_schema_errors schema.errors unless schema.call(self.conditions)
  end

  def atleast_one_action
    if file_manager_actions.blank?
      errors.add :action, 'is not defined'
      return
    end
  end

  # EventManager::Workflows::Contract::RuleSchema = Dry::Schema.Params do
  #
  # end
  #
  # EventManager::Workflows::Contract::GroupSchema = Dry::Schema.Params do
  #   required(:logic_type).filled(inclusion?: %w(group))
  #   required(:logic_operator).filled(inclusion?: %w(AND OR))
  #   optional(:rules).array do
  #     schema(EventManager::Workflows::Contract::RuleSchema)
  #   end
  # end


  class EventManager::Workflows::Contract::GroupSchema < Transactions::Schema

    params do
      required(:logic_type).filled(inclusion?: %w(group))
      required(:logic_operator).filled(inclusion?: %w(AND OR))
      required(:rules)
    end

    rule :rules do
      values.each do |value|
        type = value&.dig(:logic_type)
        case type
        when 'group'

        when 'condition'

        else

        end
      end
    end

  end
  #
  # class EventManager::Workflows::Contract::RuleSchema < Transactions::Schema
  #
  #   params do
  #     required(:logic_type).filled(inclusion?: %w(condition))
  #     required(:logic_operator).filled(inclusion?: %w(AND OR))
  #     required(:operator).filled
  #     required(:values).filled
  #   end
  #
  # end

end