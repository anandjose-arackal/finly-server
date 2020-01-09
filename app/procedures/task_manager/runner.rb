class TaskManager::Runner < Transactions::API

  class TaskManager::Runner::BackgroundJob < ApplicationJob

    def perform(options = {})
      user = User.find_by(id: options[:user_id])
      params = {}
      params[:message] = options[:message]
      params[:task_workflow_id] = options[:task_workflow_id]
      params[:api] = options[:api] if options[:api]
      TaskManager::Runner.(params, 'current_user' => user)
    end

  end

  skip_user_authorization!

  schema do
    params do
      optional(:message).filled
      optional(:api).filled
      optional(:task_workflow_api).filled
    end
  end

  step :setup
  step :applicable_for_user?
  step :validate_payload
  step :generate_input
  step :validate_input
  step :pre_process
  step :execute_actions
  step :post_process

  # return unless applicable_for_user? user, message
  # return unless validate_payload user, message
  # input = generate_input user, message
  # return unless validate_input user, message, input
  # execute_actions user, message, input

  def setup(options, current_user:, params:, **)
    options['message'] = params&.dig(:message)
    options['api'] = params&.dig(:api)
    if params&.dig(:task_workflow_id)
      options['api'] = TaskWorkflow.find_by(id: params&.dig(:task_workflow_id))
    end
    return false if options['api'].blank?

    true
  end

  def applicable_for_user?(options, api:, current_user:, message:, **)
    required_roles = api.user_roles
    return on_error(options, :base, 'Current user is blank') if current_user.blank?
    if required_roles.blank?
      # Roles is mandatory for scheduled tasks
      return true unless api.scheduled?

      return on_error(options, :base, 'Roles is not provided')
    end
    current_user_roles = current_user.user_roles.pluck(:name)
    if (required_roles - current_user_roles).size == roles.size
      return on_error(options, :base, 'Workflow is not applicable for user')
    end
    true
  end

  def validate_payload(options, api:, current_user:, message:, **)
    api.payload_validations.each do |validation|
      unless execute_function validation, current_user, message
        return on_error(options, :base, 'Payload Validation failed')
      end
    end
    true
  end

  def generate_input(options, api:, current_user:, message:, **)
    if api.input
      options['input'] = execute_function api.input, current_user, message
      return on_error(options, :base, 'Input is blank') if options['input'].blank?
    end

    return on_error(options, :base, 'Input is not provided') unless api.record

    if api.consumes_event?
      generate_event_input(options, **options)
    elsif api.scheduled?
      generate_schedule_input(options, **options)
    end
    return on_error(options, :base, 'Input is blank') if options['input'].blank?

    true
  end

  def generate_event_input(options, message:, api:, current_user:, **)
    return true unless api.consumes_event?

    record = api.record
    event = api.event

    filters = api.filters || {}

    if record.record_event?(event)
      id = message[:record_id] || message[:id]
      id = message[:record]&.id if message.has_key?(:record)
      options['input'] = record.resolve(current_user, filters: filters).find_by(id: id)
    elsif record.collection_event?(event)
      if message.has_key?(:records)
        options['input'] = message[:records].ransack(filters).result(distinct: true)
      else
        options['input'] = record.resolve(current_user, filters: filters)
      end
    else
      return on_error(options, :base, "Event #{event} is not registered")
    end

    true
  end

  def generate_schedule_input(options, api:, current_user:, **)
    return true unless api.scheduled?

    filters = api.filters
    return on_error(options, :base, 'Filters are required for scheduled tasks') if filters.blank?

    options['input'] = api.record.resolve(current_user, filters: filters)
    true
  end

  def validate_input(options, api:, current_user:, message:, input:, **)
    api.input_validations.each do |validation|
      unless execute_function validation, current_user, message, input
        return on_error(options, :base, 'Input validation error')
      end
    end
    true
  end

  def pre_process(options, api:, current_user:, message:, input:, **)
    api.pre_processes.each do |validation|
      unless execute_function validation, current_user, message, input
        return on_error(options, :base, 'Preprocess failed')
      end
    end
    true
  end

  def execute_actions(options, api:, current_user:, message:, input:, **)
    api.actions.each do |action|
      execute_function action, current_user, message, input
    end
    true
  end

  def post_process(options, api:, current_user:, message:, input:, **)
    api.pre_processes.each do |validation|
      unless execute_function validation, current_user, message, input
        return on_error(options, :base, 'Postprocess failed')
      end
    end
    true
  end

  protected

  def execute_function(function, *args)
    Transactions::Helper.execute_function(self, function, *args)
  end

end