class ActionsManager::Master::Procurements::PurchaseOrders::Invoices::Index < ActionsManager::Master::Base

  register_handle :po_invoice_index
  register_actions [
                      :export_all,
                      :bulk_approve,
                      :bulk_control,
                      :bulk_reject,
                      :bulk_forward_approval,
                      :export_xls,
                      :export_csv

                    ]

  def export_all
    true
  end

  def bulk_approve
    user.vendor_payment_admin? || user.is_po_invoice_reviewer?
  end

  def bulk_control
    user.vendor_payment_admin?
  end

  def bulk_reject
    user.vendor_payment_admin? || user.is_po_invoice_reviewer?
  end

  def bulk_forward_approval
    user.vendor_payment_admin? || user.is_po_invoice_reviewer?
  end

  def export_xls
    true
  end

  def export_csv
    true
  end


  
end