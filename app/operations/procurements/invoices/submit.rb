class Procurements::Invoices::Submit < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement, :invoice_params, :budgets

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:procurements, :invoices, :submit], :validate, self)
        }
    }
  end

  def rollback_process_if_error?
    true
  end

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.invoice = user.company.inward_invoices.scope_all_except_voided.find_by id: invoice_id
    self.procurement = self.invoice&.procurement

    fetch_budget_contributions(invoice)
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
      return
    end

    if invoice.payment_agreement_id.blank? || vendor_gstin_registered
      if self.invoice.attachments.blank?
        add_message :error, "Please attach an invoice document before submitting."
        return
      end
    end

    receiving_account = self.invoice.receiving_account
    if receiving_account&.disabled
      add_message :error, "This invoice has a bank account which is disabled. Payment can only be processed to active bank accounts."
      return
    end

    # checking for configuration on whether this particular company
    # has budgeting enforced or not
    # this will apply only if this invoice is part of a non-PO
    if self.invoice.procurement&.non_po_procurement?
      if user.company.enforce_budget_configuration.enforce_invoice_budget? && self.invoice.items.present?
        op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.invoice, current_user: User.first})
        if op.success?
          self.budgets = op["result"][:budgets]
        end
      end
      if user.company.enforce_budget_configuration.enforce_invoice_budget? && self.budgets.blank?
        add_message :error, "You cannot submit this Invoice because there are no budgets associated with it"
        return
      end
    end

    # Set validation of DLRMs
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Validate.(user, {
        reviewal_document: self.invoice,
        provider_name: self.invoice.get_invoice_provider_name
    })

    unless dlrm_validation_op.success?
      add_message :error, dlrm_validation_op.messages[:error]
    end
    validate_agreement_limit
  end

  def process
    params[:document] = self.invoice
    params[:aasm_event] = 'submit'
    params[:violation_present] = false
    params[:provider_name] = self.invoice.get_invoice_provider_name
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

    self.invoice.update(rejection_note: "")
    self.workflow_output = op.workflow_output
    
  end

  def post_process
    # Budget check
    budget_validation_op = budget_limit_validation(invoice)
    if budget_validation_op.present? && budget_validation_op.failure? && budget_validation_op.messages[:errors].present?
      add_message :error, budget_validation_op.messages[:errors]
      return
    end

    update_agreement_available_limit
    role_id = self.workflow_output[:role_id]
    Event::EInvoice::Submit.(user, {invoice: invoice, workflow_output: workflow_output, role_id: role_id})
    # Email to vendor that invoice is generated when the invoice is approved/auto_approved
    # Event::EInvoice::VendorMail.(user, invoice: invoice, workflow_output: workflow_output) if self.invoice.approved? || self.invoice.auto_approved?
    add_message :success, 'Successfully submitted invoice'
  end

  def vendor_gstin_registered
    self.invoice.vendor.gst_registered
  end
end