class Procurements::Invoices::Void < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement, :invoice_params

  def init
    invoice_id = params[:id] || params[:invoice_id]
    self.invoice = user.company.inward_invoices.find_by id: invoice_id
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
    end

    unless user.vendor_payments_admin?
      add_message :error, "Only admin is authorized to \"Void\" an Invoice."
      return
    end

    unless invoice.approved? || invoice.auto_approved?
      add_message :error, "Only approved and auto approved invoice can be voided."
      return
    end

    if self.invoice.payments.present?
      add_message :error, "Invoice has payments associated with it. It cannot be voided."
      return
    end
  end

  def process
    # if purchase order's payment's been processed then should block voiding it
    params[:document] = self.invoice
    params[:aasm_event] = 'void'
    params[:provider_name] = self.invoice.get_invoice_provider_name
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    self.workflow_output = op.workflow_output

    # todo release all the budgets #todo-sreeram
    update_associated_documents
  end

  def post_process
    add_message :success, 'Successfully Voided Invoice'
  end

  private

  def update_associated_documents
    if self.invoice.payment_agreement_id.present?
      self.invoice.agreement_item&.update is_payment_agreement_upcoming_invoice: true
    end
  end

end