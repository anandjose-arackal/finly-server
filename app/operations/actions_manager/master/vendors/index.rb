class  ActionsManager::Master::Vendors::Show < ActionsManager::Master::Base
  register_handle :vendors_index
  register_actions %i( create )


  def create
    user.is_vendor_initiator?
  end
end