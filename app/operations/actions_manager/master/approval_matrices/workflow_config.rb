class ActionsManager::Master::ApprovalMatrices::WorkflowConfig < ActionsManager::Master::Base

  register_handle :vp_workflow_config
  register_actions [:purchase_request,:purchase_order,:non_po_invoice, :invoice,:bank_payment_request,:vendor,
                    :payment_agreement,:agreement_invoices,:credit_note,:bbps_bill_subscription,:bbps_bill_auto_fetched_provider,
                    :bbps_bill_non_auto_fetched_provider]

  def purchase_request
    true
  end

  def purchase_order
    true
  end

  def non_po_invoice
    true
  end

  def invoice
    true
  end

  def bank_payment_request
    true
  end

  def vendor
    true
  end

  def payment_agreement
    true
  end

  def agreement_invoices
    true
  end

  def credit_note
    true
  end

  def bbps_bill_subscription
    true
  end

  def bbps_bill_auto_fetched_provider
    true
  end

  def bbps_bill_non_auto_fetched_provider
    true
  end

end