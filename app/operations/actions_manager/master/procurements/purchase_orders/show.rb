class ActionsManager::Master::Procurements::PurchaseOrders::Show < ActionsManager::Master::Base

  register_handle :non_po_show

  register_actions [:delete, :save_and_submit, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_invoice_items, :update]

  def delete
    user.vendor_payments_admin?
  end

  def save_and_submit
    user.vendor_payments_admin?
  end

  def more_actions
    user.vendor_payments_admin?
  end

  def make_payment
    user.vendor_payments_admin?
  end

  def audit_trail
    user.vendor_payments_admin?
  end

  def download
    user.vendor_payments_admin?
  end

  def send_btn
    user.vendor_payments_admin?
  end

  def export_invoice_items
    user.vendor_payments_admin?
  end

  def update
    user.vendor_payments_admin?
  end


end