class ActionsManager::Master::BankTransfer::AccountOwners::Index < ActionsManager::Master::Base

  register_handle :account_owners_index

  register_actions [:create_vendor, :create_payment_order, :import_vendors, :xls, :csv]


  def create_vendor
    user.admin?
  end

  def create_payment_order
    user.admin?
  end

  def import_vendors
    user.admin?
  end

  def xls
    user.admin?
  end

  def csv
    user.admin?
  end

end