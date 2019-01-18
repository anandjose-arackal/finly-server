class ActionsManager::Master::Procurements::Index < ActionsManager::Master::Base

  register_handle :procurements_index

  register_actions [:new_procurements, :bulk_actions, :approve_purchase_order, :export, :bulk_import_advances]


  def new_procurements
    user.vendor_payments_admin?
  end

  def bulk_actions
    user.vendor_payments_admin?
  end

  def approve_purchase_order
    user.vendor_payments_admin?
  end

  def export
    user.vendor_payments_admin?
  end

  def bulk_import_advances
    user.vendor_payments_admin?
  end

end