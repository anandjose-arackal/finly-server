class ActionsManager::Master::BankTransfer::AccountOwners::VendorShow < ActionsManager::Master::Base

  register_handle :beneficiaries_vendor_show
  validate :input
  register_actions [:delete_vendor, :add_bank_account, :edit_bank_account, :delete_bank_account, :edit_vendor_details, :edit_attachment, :create_beneficiaries]

  def initialize(user=nil, params={})
    super
    result = BankTransfer::AccountOwners::Show.(user, params)
    if result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.account_owner = result.account_owner
  end

  def delete_vendor
    true
  end

  def add_bank_account
    true
  end

  def edit_bank_account
    true
  end

  def delete_bank_account
    true
  end

  def edit_vendor_details
    true
  end

  def edit_attachment
    true
  end

  def create_beneficiaries
    account_owner.is_a?(YesBankVendor) && (user.permission.create_beneficiaries || user.vendor_payments_admin?)
  end


end