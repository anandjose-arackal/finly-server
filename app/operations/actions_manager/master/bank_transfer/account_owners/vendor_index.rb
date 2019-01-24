class ActionsManager::Master::BankTransfer::AccountOwners::VendorIndex < ActionsManager::Master::Base

  register_handle :beneficiaries_vendor_index
  register_actions [:create_beneficiaries]

  def create_beneficiaries
    true
  end

end