class Invoicing::Company::Reminders::Index < Invoicing::Company::Reminders::Base

  attr_accessor :reminders

  class Invoicing::Company::Reminders::Index::RemindersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :reminders

    def init
      self.reinders = params[:reminders]
    end
  end

  def init

  end

  def process
    self.reminders = user.company.invoice_reminders
  end

  def success
    params[:reminders] = self.reminders
    Invoicing::Company::Reminders::Index::RemindersPresenter.new(user, params, messages)
  end

end