class TaskManager::Workflows::API

  # Event receive
  def receive(user, message)
    return unless applicable_for_user? user, message
    return unless validate_payload user, message
    input = generate_input user, message
    return unless validate_input user, message, input
    execute_actions user, message, input
  end

  def applicable_for_user?(user, message)
    return false if self.class.users and not execute_function @user_proc, user, message
    return false if self.class.user_roles and false # Todo
    return false if self.class.document_roles and false # Todo
    true
  end

  def validate_payload(user, message)
    self.class.payload_validations.each do |validation|
      result = execute_function validation, user, message
      return false unless result
    end
    true
  end

  def generate_input(user, message)
    return message unless self.class.input

    execute_function self.class.input, user, message
  end

  def validate_input(user, message, input)
    self.class.input_validations.each do |validation|
      result = execute_function validation, user, message, input
      return false unless result
    end
    true
  end

  def execute_actions(user, message, input)
    self.class.actions.each do |action|
      execute_function action, user, message, input
    end
  end

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

  def self.event?
    @trigger == :event
  end

  def self.scheduled?
    @trigger == :schedule
  end

  def self.scheduled!(every:, hour:, minute:, day_of_the_week: nil, day_of_the_month: nil)
    raise "#{self.name} cannot consume event and be scheduled" if event?

    include TaskManager::Workflows::API::ScheduleHandler
    @trigger_type = :schedule
    @schedule = schedule
  end

  def self.consumes_event!(event)
    raise "#{self.name} cannot consume event and be scheduled" if scheduled?

    include Events::Consumer
    @trigger_type = :event
    event event
  end

  def self.users(users = nil, user_roles: nil, document_roles: nil)
    @user_proc = users
    @user_roles = user_roles
    @document_roles = document_roles
  end

  def self.validate_payload(condition)
    payload_validations << condition
  end

  def self.action(action)
    actions << action
  end

  def self.validate_input(condition)
    input_validations << condition
  end

  def self.input(input = NoObject)
    @input = input unless input == NoObject
    @input
  end

  def self.payload_validations
    @payload_validations ||= []
  end

  def self.actions
    @actions ||= []
  end

  def self.input_validations
    @input_validations ||= []
  end

  def self.users
    @user_proc
  end

  def self.user_roles
    @user_roles
  end

  def self.document_roles
    @document_roles
  end


end

# class Workflows::API
#
#   # Trigger start
#   trigger :schedule, schedule: {
#       every: TaskSchedule::EVERY[:day],
#       hour: 12,
#       minute: 0,
#       day_of_the_week: TaskSchedule::DAY_OF_THE_WEEK[:monday],
#       day_of_the_month: 1
#   }
#   trigger :event, event: 'invoice.submit'
#   users user_roles: :invoice_initiator, document_roles: :purchase_order_reviewer do
#
#   end
#   # Trigger end
#
#   # Input start
#   # input record: Invoice, conditions: [{id_in: [1, 2], status_in: [:processing]}]
#   input do
#     # Master input block which provides the list of records for running the workflow
#   end
#   rule -> (data) do
#     # Rule is used to
#     invoice = data[:invoice]
#     skip! if invoice.blank?
#     skip! if invoice.status == InwardInvoiceStatus.id_for(:processing)
#   end
#   # Input end
#
#   # Action start
#   action SubmitMailer
#   action SubmitSms do
#     action_key 'report.submit.sms'
#   end
#   # Action end
#
#   class SubmitMailer < Mailers::API
#     action_key 'report.submit.owner.email'
#   end
#
# end

