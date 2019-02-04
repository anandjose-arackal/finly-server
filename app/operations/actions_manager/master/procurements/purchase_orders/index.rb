class ActionsManager::Master::Procurements::PurchaseOrders::Index < ActionsManager::Master::Procurements::PurchaseOrders::Base

  register_handle :non_po_index
  register_actions [:new_non_po_invoice, :bulk_actions, :approve_invoices, :export_all, :bulk_import]
  alias_method :purchase_order, :input

  def new_non_po_invoice
    true
  end

  def bulk_actions
    true
  end

  def approve_invoices
    user.vendor_payments_admin? || user.vendor_payment_reviewer?
  end

  def export_all
    true
  end

  def bulk_import
    true
  end

end