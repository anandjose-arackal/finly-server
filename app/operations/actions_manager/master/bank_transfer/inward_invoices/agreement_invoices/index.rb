class ActionsManager::Master::BankTransfer::InwardInvoices::AgreementInvoices::Index < ActionsManager::Master::Base

  register_handle :agreement_invoice_index
  register_actions [
                      :bulk_approve,
                      :bulk_reject,
                      :bulk_control,
                      :bulk_forward_approval,
                      :tally_export,
                      :export_as_xls,
                      :export_as_csv,
                      :bulk_actions,
                      :export_all
                    ]


  def bulk_approve
    user.vendor_payment_admin? || user.is_non_po_invoice_reviewer?
  end

  def bulk_reject
    user.vendor_payment_admin? || user.is_non_po_invoice_reviewer?
  end

  def bulk_control
    user.vendor_payment_admin?
  end

  def bulk_forward_approval
    user.vendor_payment_admin? || user.is_non_po_invoice_reviewer?
  end

  def tally_export
    true
  end

  def export_as_xls
    true
  end

  def export_as_csv
    true
  end

  def bulk_actions
    true
  end

  def export_all
    true
  end
end