class ActionsManager::Master::Procurements::Index < ActionsManager::Master::Base

  register_handle :procurements_index
  register_actions [:new_procurements, :bulk_actions, :approve_purchase_order, :export, :bulk_import_advances, :approve_tax_invoices]


  def new_procurements
    true
  end

  def bulk_actions
    true
  end

  def approve_purchase_order
    if user.vendor_payments_admin? || user.has_policy_role?(UserRole.id_for(:purchase_request_reviewer))
      true
    end
  end

  def export
    true
  end

  def bulk_import_advances
    true
  end

  def approve_tax_invoices
    if user.vendor_payments_admin? || user.has_policy_role?(UserRole.id_for(:purchase_request_reviewer))
      return true
    end
  end
end