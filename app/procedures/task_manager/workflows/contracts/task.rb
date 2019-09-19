class TaskManager::Workflows::Contracts::Task < Transactions::Contract
  include TaskManager::Actions::FileManager::Validations

  class TaskManager::Workflows::Contracts::Task::GroupSchema < Transactions::Schema

    params do
      required(:logic_type).filled(inclusion?: %w(group))
      required(:logic_operator).filled(inclusion?: %w(AND OR))
      required(:rules)
    end

  end

  class TaskManager::Workflows::Contracts::Task::ConditionSchema < Transactions::Schema
    # %w(cont_any not_cont_any in not_in blank present lteq gteq is_in_the_range
    # lteq_days gteq_days eq_days is_in_days eq_days gteq lteq is_in_the_range)
    params do
      required(:logic_type).filled(inclusion?: %w(condition))
      required(:field_key).filled
      required(:operator).filled
      required(:values).filled
    end
  end

  def self.group_schema
    @group_schema ||= TaskManager::Workflows::Contracts::Task::GroupSchema.new
  end

  def self.condition_schema
    @condition_schema ||= TaskManager::Workflows::Contracts::Task::ConditionSchema.new
  end

  property :uuid
  property :name, validates: {presence: true}
  property :description, validates: {presence: true}
  property :model_class, validates: {presence: true, inclusion: {in: Documents::Master.list}}
  property :personal, default: false
  property :user_id, validates: {presence: true}
  property :company_id, validates: {presence: true}
  property :conditions
  property :trigger_type, validates: {presence: true, inclusion: {in: TaskWorkflow.trigger_types.values}}
  property :task_schedule, populate_if_empty: TaskSchedule do
    property :every, validates: {presence: true, inclusion: {in: TaskSchedule::EVERY.values}}
    property :hour, validates: {presence: true, inclusion: {in: (1..24).to_a}}
    property :minute, validates: {presence: true, inclusion: {in: [0, 30]}}
    property :day_of_the_week, validates: {inclusion: {in: ([nil, 0] + TaskSchedule::DAY_OF_THE_WEEK.values)}}
    property :day_of_the_month, validates: {inclusion: {in: ([nil, 0] + (1..30).to_a)}}
  end
  collection :file_manager_actions, populate_if_empty: TaskFileManagerAction do
    property :export_template_id, validates: {presence: true}
  end

  # validate :atleast_one_action
  validate :conditions_schema_validation
  validate :task_schedule_presence_validation
  validate :task_schedule_validation

  def task_schedule_presence_validation
    return unless trigger_type == TaskWorkflow.trigger_types['schedule']

    errors.add :task_schedule, 'is not set' if task_schedule.blank?
  end

  def task_schedule_validation
    return unless trigger_type == TaskWorkflow.trigger_types['schedule']
    return if task_schedule.nil?
    case task_schedule.every
    when TaskSchedule::EVERY['day']

    when TaskSchedule::EVERY['week']
      if task_schedule.day_of_the_week.blank?
        errors.add :task_schedule, {day_of_the_week: 'cannot be blank'}
      end
    when TaskSchedule::EVERY['month']
      if task_schedule.day_of_the_month.blank?
        errors.add :task_schedule, {day_of_the_month: 'cannot be blank'}
      end
    end
  end

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
      type = rule['logic_type'] || rule[:logic_type]
      case type
      when 'group'
        e = check_group_schema(rule)
      when 'condition'
        e = check_condition_schema(rule)
      else
        e = {rule: ['is invalid']}
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

  # def atleast_one_action
  #   if file_manager_actions.blank?
  #     errors.add :base, 'Action is not defined'
  #     return
  #   end
  # end
end