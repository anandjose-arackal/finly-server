class ActionsManager::Master::Vendors::Index < ActionsManager::Master::Base
  register_handle :vendors_index
  register_actions %i( create bulk_actions )


  def create
    user.is_vendor_initiator? || user.is_vendor_manager? || user.permission.create_beneficiaries
  end

  def bulk_actions
    user.company.vendor_empanelment_workflow_enabled? && (user.vendor_payments_admin? || user.is_vendor_reviewer? || user.is_vendor_manager?)
  end
end