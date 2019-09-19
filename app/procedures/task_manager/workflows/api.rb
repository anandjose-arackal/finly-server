class Workflows::API

  # Trigger start
  trigger :schedule, schedule: {
      every: TaskSchedule::EVERY[:day],
      hour: 12,
      minute: 0,
      day_of_the_week: TaskSchedule::DAY_OF_THE_WEEK[:monday],
      day_of_the_month: 1
  }
  trigger :event, event: 'invoice.submit'
  users user_roles: :invoice_initiator, document_roles: :purchase_order_reviewer do

  end
  # Trigger end

  # Input start
  # input record: Invoice, conditions: [{id_in: [1, 2], status_in: [:processing]}]
  input do
    # Master input block which provides the list of records for running the workflow
  end
  rule -> (data) do
    # Rule is used to
    invoice = data[:invoice]
    skip! if invoice.blank?
    skip! if invoice.status == InwardInvoiceStatus.id_for(:processing)
  end
  # Input end

  # Action start
  action SubmitMailer
  action SubmitSms do
    action_key 'report.submit.sms'
  end
  # Action end

  class SubmitMailer < Mailers::API
    action_key 'report.submit.owner.email'
  end

  def self.trigger(type, schedule: nil, event: nil)
    @trigger_type = type
    case type
    when :schedule
      schedule schedule
    when :event
      event event
    else
      raise "Invalid trigger type #{type} in class #{self.name}" unless [:schedule, :event].include?(type)
    end
  end

  def self.users(user_roles: nil, document_roles: nil, &block)
    @users_proc = block
  end

  def self.schedule(schedule = NoObject)
    @schedule = schedule unless schedule == NoObject
    @schedule
  end

  def self.event(event = NoObject)
    @event = event unless event == NoObject
    @event
  end

end