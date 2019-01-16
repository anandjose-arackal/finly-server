class ActionsManager::Master::Procurements::Show < ActionsManager::Master::Base

  register_handle :procurements_show

  register_actions [:add_document, :retract, :remind_approver, :void, :save_btn, :download, :save_and_submit, :delete, :more_actions, :make_payment, :audit_trail, :download, :send_btn, :export_po_items, :update_btn]

  def add_document
    user.admin?
  end

  def retract
    user.admin?
  end

  def remind_approver
    user.admin?
  end

  def void
    user.admin?
  end

  def save_btn
    user.admin?
  end

  def download
    user.admin?
  end

  def save_and_submit
    user.admin?
  end

  def delete
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

  def export_po_items
    user.admin?
  end

  def update_btn
    user.admin?
  end

end