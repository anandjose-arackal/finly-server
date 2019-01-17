class ActionsManager::Master::Procurements::PurchaseOrders::Index < ActionsManager::Master::Base

  register_handle :non_po_index

  register_actions [:new_non_po_invoice, :bulk_actions, :approve_invoices, :export_all, :bulk_import]


  def new_non_po_invoice
    user.admin?
  end

  def bulk_actions
    user.admin?
  end

  def approve_invoices
    user.admin?
  end

  def export_all
    user.admin?
  end

  def bulk_import
    user.admin?
  end

end