class Event::EReminders::UnapprovedTransaction < BaseOperation
  
  def action_name
    "Reminder Email for Unapproved Transactions"
  end

  def mailer_body(user = nil)
    "This is to send reminder email to the users who have some unapproved transactions"
  end

  def mailer_subject(user = nil)
    "Unapproved Transaction requires your attention"
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def process
    send_mailer(user)
  end

  def send_mailer(user)
    return if user.blank?
    
    set_presenter_params
    return unless params[:subject].present? && params[:body].present?
    
    params[:action_name] = action_name
    
    UnapprovedTransactionReminderMailer.delay.send_unapproved_transaction_mail(
      # Event::EReminders::UnapprovedTransaction::MailerPresenter.new(user, params)
      user&.id, params
    )
  end

  def set_presenter_params(user = nil)
    params[:subject] = self.mailer_subject
    params[:body] = self.mailer_body
  end  

  # presenter class for the reminder emails
  class MailerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :user, :company, :body, :subject, :action_name, :pending_items_count

    def initialize(user, params)
      self.user = user
      self.company = user.company
      self.body = params[:body]
      self.subject = params[:subject]
      self.action_name = params[:action_name]
      self.pending_items_count = params.extract!(:purchase_requests, :purchase_orders, :invoices,
        :utility_bills, :payment_tickets, :vendors, :agreements, :utility_subscriptions,
      )
    end

    def to
      user.email
    end
  end  
end
