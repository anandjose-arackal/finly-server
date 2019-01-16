class ActionsManager::Master::Procurements::PurchaseOrders::Show < ActionsManager::Master::Base

  register_handle :purchase_orders_show

  register_actions [:delete, :save_and_submit, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_invoice_items, :update]

  def delete
    user.admin?
  end

  def save_and_submit
    user.admin?
  end

  def more_actions
    user.admin?
  end

  def make_payment
    user.admin?
  end

  def audit_trail
    user.admin?
  end

  def download
    user.admin?
  end

  def send_btn
    user.admin?
  end

  def export_invoice_items
    user.admin?
  end

  def update
    user.admin?
  end


end