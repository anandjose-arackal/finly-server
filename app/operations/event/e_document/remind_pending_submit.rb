class Event::EDocument::RemindPendingSubmit < BaseOperation
  attr_accessor :inward_documents, :po_invoices, :non_po_invoices, :inward_document_pending_submit_columns, :po_invoice_pending_submit_columns, :non_po_pending_submit_columns


  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "Documents pending submission"
  end

  def init

    self.inward_documents = params[:inward_documents]
    self.inward_document_pending_submit_columns = ["#", "GRN #", "Proc ID", "Proc Name", "Vendor", "Created by", "Creation Date"]

    self.po_invoices = params[:po_invoices]
    self.po_invoice_pending_submit_columns = ["#", "Procurement ID", "Invoice #", "Due Date", "Balance Due", "Created by", "Created at"]

    self.non_po_invoices = params[:non_po_invoices]
    self.non_po_pending_submit_columns = ["#", "Procurement ID", "Invoice #", "Due Date", "Balance Due", "Created by", "Created at"]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name

    params[:inward_documents] = self.inward_documents
    params[:inward_document_pending_submit_columns] = self.inward_document_pending_submit_columns

    params[:po_invoices] = self.po_invoices
    params[:po_invoice_pending_submit_columns] = self.po_invoice_pending_submit_columns

    params[:non_po_invoices] = self.non_po_invoices
    params[:non_po_pending_submit_columns] = self.non_po_pending_submit_columns

    ProcurementMailer.delay.send_submit_reminder_mail(Event::EDocument::RemindPendingSubmit::MailerPresenter.new(user, params))
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
  end

  def process
    set_inward_invoice_column_values if self.inward_documents.present?
    set_non_po_column_values if self.non_po_invoices.present?
    set_po_invoice_column_values if self.po_invoices.present?

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
    "Documents pending submission"
  end

  def mailer_body(user)
    "These documents are pending your submission"
  end

  class Event::EDocument::RemindPendingSubmit::MailerPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :user, :body_val, :subject_val, :company, :action_name, :action_url, :inward_document_pending_submit, :inward_document_pending_submit_columns, :inward_document_pending_submit_column_values, :non_po_pending_submit, :non_po_pending_submit_columns, :non_po_pending_submit_columns, :non_po_pending_submit_column_values, :po_invoice_pending_submit, :po_invoice_pending_submit_columns, :po_invoice_pending_submit_column_values

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]

      setup_inward_document_section(params)
      setup_po_invoice_section(params)
      setup_non_po_invoice_section(params)
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

    private
    def setup_inward_document_section(params)
      self.inward_document_pending_submit = params[:inward_documents]
      self.inward_document_pending_submit_columns = params[:inward_document_pending_submit_columns]
      self.inward_document_pending_submit_column_values = params[:inward_document_pending_submit_column_values]
    end

    def setup_non_po_invoice_section(params)
      self.non_po_pending_submit = params[:non_po_invoices]
      self.non_po_pending_submit_columns = params[:non_po_pending_submit_columns]
      self.non_po_pending_submit_column_values = params[:non_po_pending_submit_column_values]
    end

    def setup_po_invoice_section(params)
      self.po_invoice_pending_submit = params[:po_invoices]
      self.po_invoice_pending_submit_columns = params[:po_invoice_pending_submit_columns]
      self.po_invoice_pending_submit_column_values = params[:po_invoice_pending_submit_column_values]
    end

  end


  def set_inward_invoice_column_values
    column_values = []
    self.inward_documents.each.with_index(1) do |inward_document, index|
      column_values << [index, inward_document.grn_number, inward_document.procurement_id,inward_document&.procurement&.name, inward_document&.vendor&.display_name, inward_document&.user&.name, inward_document.created_at.to_date]
    end
    if column_values.present?
      params[:inward_document_pending_submit_column_values] = column_values
    end
  end

  def set_po_invoice_column_values
    column_values = []
    self.po_invoices.each.with_index(1) do |invoice, index|
      column_values << [index, invoice.procurement_id, invoice.invoice_number, invoice.due_date, invoice&.balance_due&.value, invoice&.created_by&.name, invoice&.created_at&.to_date]
    end
    if column_values.present?
      params[:po_invoice_pending_submit_column_values] = column_values
    end
  end

  def set_non_po_column_values
    column_values = []
    self.non_po_invoices.each.with_index(1) do |invoice, index|
      column_values << [index, invoice.procurement_id, invoice.invoice_number, invoice.due_date, invoice&.balance_due&.value, invoice&.created_by&.name, invoice&.created_at&.to_date]
    end
    if column_values.present?
      params[:non_po_pending_submit_column_values] = column_values
    end
  end

end