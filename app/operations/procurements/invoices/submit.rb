class Procurements::Invoices::Submit < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement, :invoice_params

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:procurements, :invoices, :submit], :validate, self)
        }
    }
  end

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.invoice = user.company.inward_invoices.find_by id: invoice_id
    self.procurement = self.invoice&.procurement
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
    end
  end

  def process
    params[:document] = self.invoice
    params[:aasm_event] = 'submit'
    params[:violation_present] = false
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    if invoice.auto_approved?
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_processing))
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_approved))
      self.procurement.status_tags.delete(old_status_tag)
      self.procurement.status_tags << status_tag
    else
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_processing))
      unless self.procurement.status_tags.include? status_tag
        self.procurement.status_tags << status_tag
      end
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    Event::EInvoice::Submit.(user, {invoice: invoice, workflow_output: workflow_output})
    add_message :success, 'Successfully submitted invoice'
  end
end