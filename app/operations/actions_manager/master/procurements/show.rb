class ActionsManager::Master::Procurements::Show < ActionsManager::Master::Base

  register_handle :procurements_show

  register_actions [:add_document, :retract, :remind_approver, :void, :save_btn, :download, :save_and_submit, :delete, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_po_items, :update_btn]

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

  def download
    user.vendor_payments_admin?
  end

  def save_and_submit
    user.vendor_payments_admin?
  end

  def delete
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

  def export_po_items
    user.vendor_payments_admin?
  end

  def update_btn
    user.vendor_payments_admin?
  end

end