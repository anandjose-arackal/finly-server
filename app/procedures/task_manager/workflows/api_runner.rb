class TaskManager::Workflows::APIRunner < Transactions::API

  skip_user_authorization!

  schema do
    params do
      required(:message).filled
      required(:api).filled
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
    true
  end

  def applicable_for_user?(options, api:, current_user:, message:, **)
    required_roles = api.user_roles
    return on_error(options, :base, 'Roles is not provided') if required_roles.blank?
    return on_error(options, :base, 'Current user is blank') if current_user.blank?
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
    unless api.input
      return on_error(options, :base, 'Input is blank') if message.blank?

      options['input'] = message
      return true
    end

    options['input'] = execute_function api.input, current_user, message
    return on_error(options, :base, 'Input is blank') if options['input'].blank?

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
    Transactions::Helper.execute_function(function, *args)
  end

end