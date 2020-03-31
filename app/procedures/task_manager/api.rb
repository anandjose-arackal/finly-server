# ☐ Event(user, message, params)
#   ☐ Async
#     ☐ System Handler (Sneakers -> Execution)
#     ☐ Database Handler (Sneakers -> Generic Handler -> Sidekiq -> Execution)
#   ☐ Sync
#     ☐ System Handler (Execution)
#     ☐ Database Handler (Execution)
# ☐ Scheduled
#   ☐ System Handler (Clockwork -> Sidekiq -> Execution)
#   ☐ Database Handler (Clockwork -> Sidekiq -> Execution)

class TaskManager::API
  include Events::Consumer

  # TODO consume request params as well for filtering

  # When a new event is received
  def work(user, message)
    TaskManager::Runner.({api: self.class, message: message}, 'current_user' => user, 'trigger' => :event)
  end

  def on_schedule
    User.filter_role(self.user_roles).each do |user|
      TaskManager::Runner.({api: self.class}, 'current_user' => user)
    end
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

  def self.record(record=NoObject)
    @record = record unless record == NoObject
    @record
  end

  def self.input(input = NoObject)
    @input = input unless input == NoObject
    @input
  end

  def self.filters(filters=NoObject)
    @filters = filters unless filters == NoObject
    @filters
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

  def self.user_roles(*list)
    @user_roles = list if list.present?
    @user_roles ||= []
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

