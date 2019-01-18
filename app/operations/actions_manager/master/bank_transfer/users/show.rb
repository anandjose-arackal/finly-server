class ActionsManager::Master::BankTransfer::Users::Show < ActionsManager::Master::Base

  register_handle :users_show
  register_actions [:credit, :debit, :edit_policies, :add_bank_accounts, :edit_bank_accounts, :edit_configuration, :edit_permission, :edit_roles]

  def credit
    user.admin?
  end

  def debit
    user.admin?
  end

  def edit_policies
    user.admin?
  end

  def add_bank_accounts
    user.admin?
  end

  def edit_bank_accounts
    user.admin?    
  end

  def edit_configuration
    user.admin?
  end

  def edit_permission
    user.admin?
  end

  def edit_roles
    user.admin?
  end

end