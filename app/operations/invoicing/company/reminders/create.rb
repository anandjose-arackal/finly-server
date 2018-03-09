class Invoicing::Company::Reminders::Create < Invoicing::Company::Reminders::Base

  attr_accessor :reminder, :reminder_parameters

  def init
    self.reminder_parameters = reminder_params
  end

  def process
    self.reminder = user.company.invoice_reminders.build(self.reminder_parameters)
    unless self.reminder.save
      add_message :error, self.reminder.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Reminder added!"
  end
end