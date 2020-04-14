class TaskManager::Workflows::Contracts::Task < Reform::Form
  include TaskManager::Actions::FileManager::Validations

  property :uuid
  property :name, validates: {presence: true}
  property :description, validates: {presence: true}
  property :model_class, validates: {presence: true}#, inclusion: {in: Object.const_get("Documents::Master").list}}
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

  # validate :conditions_schema_validation
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

  def self.validate_schema(conditions)
    errors = Filters::Schema::Validation.check(conditions)
    add_schema_errors errors if errors
  end

end