class Procurements::Invoices::Retract < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement, :invoice_params

  def personalizer
    {
        post_process: {
            after: Personalizer::Process.new([:procurements, :invoices, :retract], :post_process, self)
        },
        validate: {
            after: Personalizer::Process.new([:procurements, :invoices, :retract], :validate, self )
        }
    }
  end

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
    params[:aasm_event] = 'retract'
    params[:violation_present] = false #todo Check violations
    params[:provider_name] = self.invoice.get_invoice_provider_name
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    self.workflow_output = op.workflow_output
    update_agreement_available_limit
  end

  def post_process
    role_id = self.workflow_output[:role_id]
    Event::EInvoice::Retract.(user, invoice: invoice, workflow_output: workflow_output, role_id: role_id)
    add_message :success, 'Successfully Retracted Invoice'
  end
end