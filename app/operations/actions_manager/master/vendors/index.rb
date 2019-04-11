class ActionsManager::Master::Vendors::Index < ActionsManager::Master::Base
  register_handle :vendors_index
  register_actions %i( create )


  def create
    user.is_vendor_initiator?
  end

  def bulk_actions
    user.vendor_payments_admin? || user.is_vendor_reviewer? || user.is_vendor_manager?
  end
  
end