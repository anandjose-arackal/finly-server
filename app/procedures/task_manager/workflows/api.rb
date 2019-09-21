class TaskManager::Workflows::API

  # When a new event is received
  def receive(user, message)
    TaskManager::Workflows::APIRunner.({api: self.class, message: message}, 'current_user' => user)
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
    raise "Condition cannot be blank in #{self.name}" if condition.nil?

    payload_validations << condition
  end

  def self.action(action)
    raise "Action cannot be blank in #{self.name}" if action.nil?

    actions << action
  end

  def self.validate_input(condition)
    raise "Input cannot be blank in #{self.name}" if condition.nil?

    input_validations << condition
  end

  def self.input(input = NoObject)
    @input = input unless input == NoObject
    @input
  end

  def self.pre_process(pre_process)
    raise "PreProcess cannot be blank in #{self.name}" if pre_process.nil?

    pre_processes << pre_process
  end

  def self.post_process(post_process)
    raise "PreProcess cannot be blank in #{self.name}" if post_process.nil?

    post_processes << post_process
  end

  def self.success(success_process)
    raise "PreProcess cannot be blank in #{self.name}" if success_process.nil?

    success_processes << success_process
  end

  def self.failed(failed_process)
    raise "PreProcess cannot be blank in #{self.name}" if failed_process.nil?

    failed_processes << failed_process
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

  def self.pre_processes
    @pre_processes ||= []
  end

  def self.post_processes
    @post_processes ||= []
  end

  def self.success_processes
    @success_processes ||= []
  end

  def self.failed_processes
    @failed_processes ||= []
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

