class  ActionsManager::Master::Vendors::Show < ActionsManager::Master::Base
  register_handle :vendor_show
  register_actions %i( submit approve reject delete add_bank_account edit_bank_account delete_bank_account edit_vendor_details edit_attachment )

  def initialize(user=nil, params={})
    super
    result = ::Vendors::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.vendor = result.vendor
  end


  def submit
    vendor.created_by.id == user.id && (YesBankVendor.status_ids(:retracted, :rejected, :draft).include? vendor.status_id)
  end

  def approve
    vendor.get_reviewers(user) && YesBankVendor.status_ids(:awaiting_approval).include?(vendor.status_id)
  end 

  def reject
    vendor.get_reviewers(user) && YesBankVendor.status_ids(:awaiting_approval).include?(vendor.status_id)
  end

  def delete
    user.is_vendor_manger?
  end

  def add_bank_account
    user.is_vendor_manger? || vendor.get_reviewers.include?(user)
  end

  def edit_bank_account
    user.is_vendor_manger? || vendor.get_reviewers.include?(user)
  end

  def delete_bank_account
    user.is_vendor_manger? || vendor.get_reviewers.include?(user)
  end

  def edit_vendor_details
    user.is_vendor_manger? || vendor.get_reviewers.include?(user)
  end

  def edit_attachment
    user.is_vendor_manger? || vendor.get_reviewers.include?(user)
  end

  def create_beneficiaries
    account_owner.is_a?(YesBankVendor) && (user.permission.create_beneficiaries || user.vendor_payments_admin?)
  end
end