class Invoicing::Company::Reminders::Update < Invoicing::Company::Reminders::Base

  attr_accessor :reminder, :reminder_parameters

  def init
    id = params[:id] || params[:reminder_id]
    self.reminder = user.company.invoice_reminders.find_by(id: id)
    self.reminder_parameters = reminder_params
  end

  def validate
    if self.reminder.blank?
      add_message :error, "Reminder not found"
    end
  end

  def process
    unless self.reminder.update(self.reminder_parameters)
      add_message :error, self.reminder.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Reminder updated successfully"
  end
end