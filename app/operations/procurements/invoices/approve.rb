class Procurements::Invoices::Approve < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement, :invoice_params

  def personalizer
    {
        post_process: {
            after: Personalizer::Process.new([:procurements, :invoices, :approve], :post_process, self)
        }
    }
  end

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.invoice = user.company.inward_invoices.scope_all_except_voided.find_by id: invoice_id

    self.procurement = self.invoice&.procurement
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
    end
    receiving_account = self.invoice.receiving_account
    if receiving_account&.disabled
      add_message :error, "This invoice has a bank account which is disabled. Payment can only be processed to active bank accounts."
      return false
    end

    validate_agreement_limit
  end

  def process
    params[:document] = self.invoice
    params[:aasm_event] = 'approve'
    params[:violation_present] = false #todo Check violations
    params[:provider_name] = self.invoice.get_invoice_provider_name
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    if invoice.approved? || invoice.auto_approved?
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_processing))
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_approved))
      self.procurement.status_tags.delete(old_status_tag)
      self.procurement.status_tags << status_tag

      invoice.update payable: true

      # if invoice final amount comes to zero, probably because so much advance was adjusted, then auto mark it as paid
      if invoice.balance_due&.value == 0
        params[:document] = self.invoice
        params[:aasm_event] = 'paid'
        params[:violation_present] = false #todo Check violations
        params[:provider_name] = self.invoice.get_invoice_provider_name
        op = WorkflowManager::Base.(user, params)
        unless op.success?
          add_message :error, op.messages[:error]
          return
        end
      end

    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    budget_limit_validation( invoice )
    update_agreement_available_limit
    Event::EInvoice::Approve.(user, invoice: invoice, workflow_output: workflow_output)
    # Email to vendor that invoice is generated when the invoice is approved
    # Event::EInvoice::VendorMail.(user, invoice: invoice, workflow_output: workflow_output) if self.invoice.approved? || self.invoice.auto_approved?
    add_message :success, 'Successfully Approved Invoice'
  end
end