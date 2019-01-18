class ActionsManager::Master::BankTransfer::Users::Index < ActionsManager::Master::Base

  register_handle :users_index
  register_actions [:add_users]

  def add_users
    user.admin?
  end

  
end