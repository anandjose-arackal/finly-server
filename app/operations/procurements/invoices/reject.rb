class Procurements::Invoices::Reject < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement, :invoice_params

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.invoice = user.company.inward_invoices.find_by id: invoice_id
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
    end
  end

  def process
    params[:document] = self.invoice
    params[:aasm_event] = 'reject'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
    end
    self.workflow_output = op.workflow_output
  end

  def post_process
    role_id = self.workflow_output[:role_id]
    Event::EInvoice::Reject.(user, invoice: invoice, workflow_output: workflow_output, role_id: role_id)
    add_message :success, 'Successfully Rejected Invoice'
  end
end