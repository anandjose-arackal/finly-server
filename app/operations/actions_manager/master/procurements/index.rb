class ActionsManager::Master::Procurements::Index < ActionsManager::Master::Base

  register_handle :procurements_index
  register_actions [:new_procurements, :bulk_actions, :approve_purchase_order, :export, :bulk_import_advances]


  def new_procurements
    true
  end

  def bulk_actions
    true
  end

  def approve_purchase_order
    true
  end

  def export
    true
  end

  def bulk_import_advances
    true
  end

end