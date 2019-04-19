# this operation is the reverse of take control, in the sense that it return control to whoever the person
# was from whom control was taken
class Procurements::Invoices::ReturnControl < Procurements::Invoices::Base

  attr_accessor :invoice, :procurement

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.invoice = user.company.inward_invoices.admin_associated_items(user).find_by id: invoice_id

    self.procurement = self.invoice&.procurement
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    unless user.vendor_payment_admin?
      add_message :error, "Only admins can return control of an invoice."
      return
    end

    unless invoice.can_return_control?
      add_message :error, "Invoice cannot be return controlled of at this stage"
      return
    end
  end


  def process
    params[:document] = self.invoice
    params[:aasm_event] = 'return_control'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    # Event::EInvoice::ReturnControl.(user, invoice: invoice, workflow_output: workflow_output)

    add_message :success, "Administrative control of Invoice sucessfully removed."
  end


end