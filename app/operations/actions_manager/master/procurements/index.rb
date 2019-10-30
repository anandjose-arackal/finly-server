class ActionsManager::Master::Procurements::Index < ActionsManager::Master::Base

  register_handle :procurements_index
  register_actions [
                      :new_procurements,
                      :approve_purchase_order,
                      :export,
                      :approve_tax_invoices,
                      :forward_purchase_orders,
                      :bulk_control_po,
                      :bulk_approve_po,
                      :bulk_reject_po,
                      :bulk_approve_forward_po,
                      :export_csv,
                      :export_xls,
                      :bulk_actions
                    ]


  def new_procurements
    user.is_purchase_order_initiator?
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
    user.is_po_invoice_reviewer?
  end

  def bulk_control_po
    user.vendor_payment_admin?
  end

  def bulk_approve_po
    user.vendor_payment_admin? || user.is_purchase_order_reviewer?
  end

  def bulk_reject_po
    user.vendor_payment_admin? || user.is_purchase_order_reviewer?
  end

  def bulk_approve_forward_po
    user.vendor_payment_admin? || user.is_purchase_order_reviewer?
  end

  def bulk_actions
    true
  end

  def export_csv
    true
  end

  def export_xls
    true
  end
end