class ActionsManager::Master::Procurements::Index < ActionsManager::Master::Base

  register_handle :procurements_index
  register_actions [:new_procurements, :bulk_actions, :approve_purchase_order, :export, :approve_tax_invoices]


  def new_procurements
    true
  end

  def bulk_actions
    true
  end

  def approve_purchase_order
    user.is_purchase_order_reviewer?
  end

  def export
    true
  end

  def approve_tax_invoices
    user.is_invoice_reviewer?
  end
end