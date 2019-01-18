class ActionsManager::Master::BankTransfer::AccountOwners::VendorShow < ActionsManager::Master::Base

  register_handle :beneficiaries_vendor_show
  register_actions [:delete_vendor, :add_bank_account, :edit_bank_account, :delete_bank_account, :edit_vendor_details, :edit_attachment]

  def delete_vendor
    user.admin?
  end

  def add_bank_account
    user.admin?
  end

  def edit_bank_account
    user.admin?
  end

  def delete_bank_account
    user.admin?
  end

  def edit_vendor_details
    user.admin?
  end

  def edit_attachment
    user.admin?
  end


end