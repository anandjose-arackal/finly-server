# submit_pending_columns = Columns in the email template 
class Event::EInwardDocument::SubmitPending < BaseOperation

  attr_accessor :inward_documents, :submit_pending_columns, :procurements

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "GRN's pending submission"
  end

  def init
    self.inward_documents = params[:inward_documents]
    self.submit_pending_columns = ["#", "GRN #", "PO #", "Proc Name", "Vendor", "Created by", "Creation Date"]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name
    params[:submit_pending_columns] = submit_pending_columns
    ProcurementMailer.delay.send_submit_reminder_mail(Event::EInwardDocument::SubmitPending::MailerPresenter.new(user, params))
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
  end

  def validate
    if self.inward_documents.blank?
      add_message :error, "Grn not found"
    end
  end 

  def process
    # Email is in form of table. Set column values against column names
    set_column_values
    send_mailer(user)
  end

  def event_id
    nil
  end

  def affected_users
  end

  def notification_affected_users
  end

  def set_notification(user)
  end

  def mailer_subject(user)
    "GRN's pending submission"
  end

  def mailer_body(user)
    "These Grn's are pending from your end for submission"
  end

  class Event::EInwardDocument::SubmitPending::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :user, :body_val, :subject_val, :company, :inward_documents, :action_name, :action_url, :pending_submissions, :pending_submission_columns, :pending_submission_column_values

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
      self.pending_submissions = params[:inward_documents]
      self.pending_submission_columns = params[:submit_pending_columns]
      self.pending_submission_column_values = params[:pending_submission_column_values]
    end

    def to
      user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end
  end

  private
  def set_column_values
    column_values = []
    self.inward_documents.each.with_index(1) do |inward_document, index|
      column_values << [index, inward_document.grn_number, inward_document&.procurement&.purchase_order&.po_number,inward_document&.procurement&.name, inward_document&.vendor&.display_name, inward_document&.user&.name, inward_document.created_at.to_date]
    end
    if column_values.present?
      params[:pending_submission_column_values] = column_values
    end
  end
end