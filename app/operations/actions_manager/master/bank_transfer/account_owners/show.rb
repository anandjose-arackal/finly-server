class ActionsManager::Master::BankTransfer::AccountOwners::Show < ActionsManager::Master::Base

  register_handle :beneficiaries_show

  register_actions [:delete]


  def delete
    user.admin?
  end
  
end