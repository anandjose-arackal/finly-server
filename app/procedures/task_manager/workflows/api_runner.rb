class TaskManager::Workflows::APIRunner < Transactions::API

  skip_user_authorization!

  # schema do
  #   params do
  #     required(:message).filled
  #     required(:api).filled
  #   end
  # end

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
    # params = options['params']
    options['message'] = params&.dig(:message)
    options['api'] = params&.dig(:api)
    true
  end

  def applicable_for_user?(options, api:, current_user:, message:, **)
    return false if api.users and not execute_function api.users, current_user, message
    return false if api.user_roles and false # Todo
    return false if api.document_roles and false # Todo
    true
  end

  def validate_payload(options, api:, current_user:, message:, **)
    api.payload_validations.each do |validation|
      return false unless execute_function validation, current_user, message
    end
    true
  end

  def generate_input(options, api:, current_user:, message:, **)
    unless api.input
      options['input'] = message
      return true
    end

    options['input'] = execute_function api.input, current_user, message
    return false if options['input'].blank?

    true
  end

  def validate_input(options, api:, current_user:, message:, input:, **)
    api.input_validations.each do |validation|
      return false unless execute_function validation, current_user, message, input
    end
    true
  end

  def pre_process(options, api:, current_user:, message:, input:, **)
    api.pre_processes.each do |validation|
      return false unless execute_function validation, current_user, message, input
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
      return false unless execute_function validation, current_user, message, input
    end
    true
  end
  
  protected

  def execute_function(function, *args)
    if function.is_a?(Proc) or function.is_a?(Class)
      function.call(*args)
    elsif function.is_a?(Symbol)
      raise "#{function} is not defined" unless self.respond_to?(function)
      self.send(function, *args)
    else
      raise "Invalid function #{function}"
    end
  end

end