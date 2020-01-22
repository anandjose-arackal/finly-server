class Event::EDocument::RemindAwaitingApproval < BaseOperation

  attr_accessor :purchase_requests, :purchase_request_awaiting_approval_columns, :non_po_awaiting_approval_columns, :non_po_invoices, :bpr_awaiting_approval_columns, :bank_payment_requests, :po_awaiting_approval_columns, :purchase_orders, :po_invoices, :po_invoice_awaiting_approval_columns

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "Documents awaiting approval"
  end

  def init
    self.purchase_requests = params[:purchase_requests]
    self.purchase_request_awaiting_approval_columns = ["#", "PR #", "Created By", "Location", "Amount"]

    self.non_po_invoices = params[:non_po_invoices]
    self.non_po_awaiting_approval_columns = ["#", "NonPO#", "Created By", "Balance Due"]

    self.po_invoices = params[:po_invoices]
    self.po_invoice_awaiting_approval_columns = ["#", "PO#", "Created By", "Balance Due"]

    self.bank_payment_requests = params[:bank_payment_requests]
    self.bpr_awaiting_approval_columns = ["#", "PT #", "Initiating User", "Scheduled Date", "Requested Amount"]

    self.purchase_orders = params[:purchase_orders]
    self.po_awaiting_approval_columns = ["#", "PO #", "Created By", "Sub Department", "Amount"]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name

    params[:purchase_requests] = self.purchase_requests
    params[:purchase_request_awaiting_approval_columns] = purchase_request_awaiting_approval_columns
    
    params[:non_po_invoices] = self.non_po_invoices
    params[:non_po_awaiting_approval_columns] = non_po_awaiting_approval_columns

    params[:po_invoices] = self.po_invoices
    params[:po_invoice_awaiting_approval_columns] = po_invoice_awaiting_approval_columns

    params[:bank_payment_requests] = self.bank_payment_requests
    params[:bpr_awaiting_approval_columns] = bpr_awaiting_approval_columns
    
    params[:purchase_orders] = self.purchase_orders
    params[:po_awaiting_approval_columns] = po_awaiting_approval_columns

    ProcurementMailer.delay.send_awaiting_approval_mail(Event::EDocument::RemindAwaitingApproval::MailerPresenter.new(user, params))
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
  end

  def validate
    # if self.purchase_requests.blank?
    #   add_message :error, "Purchase request not found"
    # end

    # if self.non_po_invoices.blank?
    #   add_message :error, "NonPO Invoices not found"
    # end

    # if self.bank_payment_requests.blank?
    #   add_message :error, "Payment Ticket not found"
    # end

    # if self.purchase_orders.blank?
    #   add_message :error, "Purchase Order not found"
    # end    
  end 

  def process
    # Email is in form of table. Set column values against column names
    set_purchase_request_column_values if self.purchase_requests.present?
    set_non_po_column_values if self.non_po_invoices.present?
    set_po_invoice_column_values if self.po_invoices.present?
    set_bpr_column_values if self.bank_payment_requests.present?
    set_po_column_values if self.purchase_orders.present?

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
    "Documents awaiting your approval"
  end

  def mailer_body(user)
    "These documents are awaiting your approval"
  end

  class Event::EDocument::RemindAwaitingApproval::MailerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :user, :body_val, :subject_val, :company, :action_name, :action_url, :purchase_request_awaiting_approvals, :purchase_request_awaiting_approval_columns, :purchase_request_awaiting_approval_column_values, :non_po_awaiting_approvals, :non_po_awaiting_approval_columns, :non_po_awaiting_approval_column_values,
      :po_invoice_awaiting_approvals, :po_invoice_awaiting_approval_columns, :po_invoice_awaiting_approval_column_values, :bpr_awaiting_approvals, :bpr_awaiting_approval_columns, :bpr_awaiting_approval_column_values, :po_awaiting_approvals, :po_awaiting_approval_columns, :po_awaiting_approval_column_values

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]

      setup_purchase_request_section(params)
      setup_non_po_invoice_section(params)
      setup_po_invoice_section(params)
      setup_bank_payment_request_section(params)
      setup_po_section(params)
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

    def setup_purchase_request_section(params)
      self.purchase_request_awaiting_approvals = params[:purchase_requests]
      self.purchase_request_awaiting_approval_columns = params[:purchase_request_awaiting_approval_columns]
      self.purchase_request_awaiting_approval_column_values = params[:purchase_request_awaiting_approval_column_values]
    end

    def setup_non_po_invoice_section(params)
      self.non_po_awaiting_approvals = params[:non_po_invoices]
      self.non_po_awaiting_approval_columns = params[:non_po_awaiting_approval_columns]
      self.non_po_awaiting_approval_column_values = params[:non_po_awaiting_approval_column_values]
    end

    def setup_po_invoice_section(params)
      self.po_invoice_awaiting_approvals = params[:po_invoices]
      self.po_invoice_awaiting_approval_columns = params[:po_invoice_awaiting_approval_columns]
      self.po_invoice_awaiting_approval_column_values = params[:po_invoice_awaiting_approval_column_values]
    end

    def setup_bank_payment_request_section(params)
      self.bpr_awaiting_approvals = params[:bank_payment_requests]
      self.bpr_awaiting_approval_columns = params[:bpr_awaiting_approval_columns]
      self.bpr_awaiting_approval_column_values = params[:bpr_awaiting_approval_column_values]
    end

    def setup_po_section(params)
      self.po_awaiting_approvals = params[:purchase_orders]
      self.po_awaiting_approval_columns = params[:po_awaiting_approval_columns]
      self.po_awaiting_approval_column_values = params[:po_awaiting_approval_column_values]
    end
  end

  private
  def set_purchase_request_column_values
    column_values = []
    self.purchase_requests.each.with_index(1) do |purchase_request, index|
      total_amount = precision_value(purchase_request.total_amount&.value || 0)
      column_values << [index, purchase_request.order_number, purchase_request.creator&.name, purchase_request&.location&.name, "Rs " + total_amount.to_s]
    end
    if column_values.present?
      params[:purchase_request_awaiting_approval_column_values] = column_values
    end
  end

  def set_non_po_column_values
    column_values = []
    self.non_po_invoices.each.with_index(1) do |invoice, index|
      balance_due = precision_value(invoice.balance_due&.value || 0)
      column_values << [index, invoice.invoice_number, invoice.created_by&.name, "Rs " + balance_due.to_s]
    end
    if column_values.present?
      params[:non_po_awaiting_approval_column_values] = column_values
    end
  end

  def set_po_invoice_column_values
    column_values = []
    self.po_invoices.each.with_index(1) do |invoice, index|
      balance_due = precision_value(invoice.balance_due&.value || 0)
      column_values << [index, invoice.invoice_number, invoice.created_by&.name, "Rs " + balance_due.to_s]
    end
    if column_values.present?
      params[:po_invoice_awaiting_approval_column_values] = column_values
    end
  end

  def set_bpr_column_values
    column_values = []
    self.bank_payment_requests.each.with_index(1) do |payment_request, index|
      requested_amount = precision_value(payment_request.payment_order.amount_requested&.value || 0)
      scheduled_at = payment_request.payment_order.scheduled_at.strftime('%d %b %Y') rescue nil
      column_values << [index, payment_request.id, payment_request&.payment_order&.initiating_user&.name, scheduled_at, "Rs " + requested_amount.to_s]
    end
    if column_values.present?
      params[:bpr_awaiting_approval_column_values] = column_values
    end
  end

  def set_po_column_values
    column_values = []
    self.purchase_orders.each.with_index(1) do |purchase_order, index|
      balance_amount = precision_value(purchase_order.balance_amount&.value || 0)
      column_values << [index, purchase_order.po_number, purchase_order.user&.name, purchase_order&.sub_department&.name, "Rs " + balance_amount.to_s]
    end
    if column_values.present?
      params[:po_awaiting_approval_column_values] = column_values
    end
  end

end