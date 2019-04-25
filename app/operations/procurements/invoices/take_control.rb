class Procurements::Invoices::TakeControl < Procurements::Invoices::Base

  attr_accessor :invoice, :procurement

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    # todo scope it and in all similar places
    self.invoice = user.company.inward_invoices.admin_associated_items(user).find_by id: invoice_id

    self.procurement = self.invoice&.procurement
  end

  def validate
    unless user.vendor_payment_admin?
      add_message :error, "Only admins can take control of an invoice."
      return
    end

    unless invoice.can_take_control?
      add_message :error, "Invoice cannot be taken control of at this stage"
      return
    end
  end


  def process
    params[:document] = self.invoice
    params[:aasm_event] = 'take_control'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    # Event::EInvoice::TakeControl.(user, invoice: invoice, workflow_output: workflow_output)

    add_message :success, "Invoice is now in your control."
  end


end