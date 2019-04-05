class Procurements::Invoices::Submit < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement, :invoice_params, :budgets

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

    if self.invoice.attachments.blank?
      add_message :error, "Please attach an invoice document before submitting."
      return
    end

    # checking for configuration on whether this particular company
    # has budgeting enforced or not
    # this will apply only if this invoice is part of a non-PO
    if self.invoice.procurement&.non_po_procurement?
      if self.invoice.items.present?
        op = BudgetsCalculator::RelevantBudgets.(user, object: self.invoice)
        if op.success?
          self.budgets = op.budget_data
        end
      end
      if user.company.enforce_budget_configuration.enforce_invoice_budget? && self.budgets.empty?
        add_message :error, "You cannot submit this Invoice because there are no budgets associated with it"
        return
      end
    end

    # Set validation of DLRMs
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Validate.(user, {
        reviewal_document: self.invoice
    })

    unless dlrm_validation_op.success?
      add_message :error, dlrm_validation_op.messages[:error]
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
    role_id = self.workflow_output[:role_id]
    Event::EInvoice::Submit.(user, {invoice: invoice, workflow_output: workflow_output, role_id: role_id})
    add_message :success, 'Successfully submitted invoice'
  end
end