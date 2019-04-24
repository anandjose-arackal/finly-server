class ActionsManager::Master::Procurements::Index < ActionsManager::Master::Base

  register_handle :procurements_index
  register_actions [:new_procurements, :bulk_actions, :approve_purchase_order, :export, :approve_tax_invoices, :forward_purchase_orders]


  def new_procurements
    user.is_purchase_order_initiator?
  end

  def bulk_actions
    user.vendor_payments_admin? || user.is_purchase_order_reviewer?
  end

  def approve_purchase_order
    user.is_purchase_order_reviewer?
  end

  def forward_purchase_orders
    user.is_purchase_order_reviewer? || user.vendor_payment_admin?
  end

  def export
    true
  end

  def approve_tax_invoices
    user.is_invoice_reviewer?
  end
end