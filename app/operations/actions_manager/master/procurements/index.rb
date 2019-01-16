class ActionsManager::Master::Procurements::Index < ActionsManager::Master::Base

  register_handle :procurements_index

  register_actions [:new_procurements, :bulk_actions, :approve_purchase_order, :export, :bulk_import_advances]


  def new_procurements
    user.admin?
  end

  def bulk_actions
    user.admin?
  end

  def approve_purchase_order
    user.admin?
  end

  def export
    user.admin?
  end

  def bulk_import_advances
    user.admin?
  end

end