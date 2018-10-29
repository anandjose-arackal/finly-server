class Event::EInvoice::BulkImport < Event::EPurchaseOrder::Base
  attr_accessor :bulk_approve_result

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.bulk_approve_result = params[:result]
  end

  def validate
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:bulk_approve_result] = self.bulk_approve_result
    ProcurementMailer.delay.invoices_bulk_import(Event::EInvoice::BulkImport::MailerPresenter.new(user, params))
  end

  def process
    send_mailer(user)
  end

  def event_id
    nil
  end

  def affected_users
  end

  def notification_affected_users
    []
  end

  def set_notification(user)
  end

  def mailer_subject(user)
    "Imported invoices in Bulk"
  end

  def mailer_body(user)
    "You have successfully imported invoices"
  end

  class Event::EInvoice::BulkImport::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :user, :body_val, :subject_val, :button_val, :company, :approval_results

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.approval_results = params[:bulk_approve_result]
    end

    def validate
      self.user.present?
    end

    def to
      self.user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end
  end
end
