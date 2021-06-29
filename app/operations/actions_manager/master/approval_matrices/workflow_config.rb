class ActionsManager::Master::ApprovalMatrices::WorkflowConfig < ActionsManager::Master::Base

  register_handle :vp_workflow_config
  register_actions [:purchase_request,:purchase_order,:non_po_invoice, :invoice,:bank_payment_request,:vendor,
                    :payment_agreement,:agreement_invoices,:credit_note,:bbps_bill_subscription,:bbps_bill_auto_fetched_provider,
                    :bbps_bill_non_auto_fetched_provider]

  def purchase_request
    user.company.purchase_requisition_enabled?
  end

  def purchase_order
    user.company.procurement_enabled?
  end

  def non_po_invoice
    user.company.invoice_to_pay_system_enabled?
  end

  def invoice
    user.company.procurement_enabled?
  end

  def bank_payment_request
    true
  end

  def vendor
    user.company.vendor_empanelment_workflow_enabled?
  end

  def payment_agreement
    user.company.agreement_based_payment_system_enabled?
  end

  def agreement_invoices
    user.company.agreement_based_payment_system_enabled?
  end

  def credit_note
    true
  end

  def bbps_bill_subscription
    user.company.utility_bills_enabled?
  end

  def bbps_bill_auto_fetched_provider
    user.company.utility_bills_enabled?
  end

  def bbps_bill_non_auto_fetched_provider
    user.company.utility_bills_enabled?
  end

end