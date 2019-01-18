class ActionsManager::Master::Procurements::PurchaseOrders::Index < ActionsManager::Master::Base

  register_handle :non_po_index

  register_actions [:new_non_po_invoice, :bulk_actions, :approve_invoices, :export_all, :bulk_import]


  def new_non_po_invoice
    user.vendor_payments_admin?
  end

  def bulk_actions
    user.vendor_payments_admin?
  end

  def approve_invoices
    user.vendor_payments_admin? || user.vendor_payment_reviewer?
  end

  def export_all
    user.vendor_payments_admin?
  end

  def bulk_import
    user.vendor_payments_admin?
  end

end