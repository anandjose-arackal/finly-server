class Invoicing::Company::Reminders::Show < Invoicing::Company::Reminders::Base

  attr_accessor :reminder

  class Invoicing::Company::Reminders::Show::ReminderPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :reminder

    def init
      self.reminder = params[:reminder]
    end

  end

  def init
    id = params[:id] || params[:reminder_id]
    self.reminder = user.company.invoice_reminders.find_by(id: id)
  end

  def validate
    if self.reminder.blank?
      add_message :error, "Reminder not found!"
    end
  end

  def success
    params[:reminder] = self.reminder
    Invoicing::Company::Reminders::Show::ReminderPresenter.new(user, params, messages)
  end
end