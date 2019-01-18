class ActionsManager::Master::Procurements::PurchaseOrders::Show < ActionsManager::Master::Base

  register_handle :non_po_show


  register_actions [:more_details_button, :send_mail, :export_items, :submit, :reject, :close, :approve, :remind ,:add_document, :retract, :remind_approver, :void, :save_btn, :export_po_items, :update_btn, :delete, :save_and_submit, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_invoice_items]

  def more_details_button
    user.vendor_payments_admin?
  end
  
  def send_mail
    user.vendor_payments_admin?
  end
  
  def export_items
    user.vendor_payments_admin?
  end

  def submit
    user.vendor_payments_admin?
  end

  def reject
    user.vendor_payments_admin?
  end

  def close
    user.vendor_payments_admin?
  end

  def approve
    user.vendor_payments_admin?
  end

  def remind
    user.vendor_payments_admin?
  end

  def add_document
    user.vendor_payments_admin?
  end

  def retract
    user.vendor_payments_admin?
  end

  def remind_approver
    user.vendor_payments_admin?
  end

  def void
    user.vendor_payments_admin?
  end

  def save_btn
    user.vendor_payments_admin?
  end

  def export_po_items
    user.vendor_payments_admin?
  end

  def update_btn
    user.vendor_payments_admin?
  end

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

end