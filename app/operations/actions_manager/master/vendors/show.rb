class  ActionsManager::Master::Vendors::Show < ActionsManager::Master::Base
  register_handle :vendor_show
  # register_actions %i( submit retract approve reject delete add_bank_account edit_bank_account delete_bank_account edit_vendor_details edit_attachment )
  register_actions %i( submit retract approve reject edit take_control delete return_control deactivate reactivate )

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
    vendor.created_by_id == user.id && (YesBankVendor.status_ids(:retracted, :rejected, :draft).include? vendor.status_id)
  end

  def retract
    vendor.created_by_id == user.id && (YesBankVendor.status_ids(:awaiting_approval).include?(vendor.status_id))
  end

  def approve
    vendor.get_reviewers.include?(user) && YesBankVendor.status_ids(:awaiting_approval).include?(vendor.status_id)
  end 

  def reject
    vendor.get_reviewers.include?(user) && YesBankVendor.status_ids(:awaiting_approval).include?(vendor.status_id)
  end

  def delete
    (vendor.draft? || vendor.retracted? || vendor.rejected?) && (vendor.created_by_id == user.id || user.is_vendor_manager? || user.vendor_payment_admin?)
  end

  def deactivate
    (vendor.approved? || vendor.auto_approved?) && (user.is_vendor_manager? || user.vendor_payment_admin?)
  end

  def reactivate
    vendor.deactivated? && (user.is_vendor_manager? || user.vendor_payment_admin?)
  end

  def edit
    (user.is_vendor_manager? || user.vendor_payment_admin? || user.permission.create_beneficiaries) || (vendor.created_by_id == user.id && YesBankVendor.status_ids(:retracted, :draft, :rejected).include?(vendor.status_id)) || (vendor.get_reviewers.include?(user) && vendor.awaiting_approval?)
  end

  def take_control
    if user.vendor_payment_admin? && (YesBankVendor.status_ids(:awaiting_approval).include?(vendor.status_id)) && user_can_take_control?
      true
    end
  end

  def return_control
    if user.vendor_payment_admin? && (YesBankVendor.status_ids(:awaiting_approval).include?(vendor.status_id)) && user_can_return_control?
      true
    end
  end

  def user_can_take_control?
    # check for the current level if it isn't taken control
    # check if the same user is not taking control twice
    # check if for the same level if any other user has also taken control
    (vendor.dlrms&.find_by(level_id: vendor.level&.id).taken_control_by_id != user.id) && !vendor.action_users(:approve).include?(user)
  end

  def user_can_return_control?
    vendor.dlrms&.find_by(level_id: vendor.level&.id).taken_control &&
    vendor.dlrms&.find_by(level_id: vendor.level&.id).taken_control_by_id == user.id
  end


  # def add_bank_account
  #   user.is_vendor_manager? || vendor.get_reviewers.include?(user)
  # end

  # def edit_bank_account
  #   user.is_vendor_manager? || vendor.get_reviewers.include?(user)
  # end

  # def delete_bank_account
  #   user.is_vendor_manager? || vendor.get_reviewers.include?(user)
  # end

  # def edit_vendor_details
  #   user.is_vendor_manager? || vendor.get_reviewers.include?(user)
  # end

  # def edit_attachment
  #   user.is_vendor_manager? || vendor.get_reviewers.include?(user)
  # end

  # def create_beneficiaries
  #   account_owner.is_a?(YesBankVendor) && (user.permission.create_beneficiaries || user.vendor_payments_admin?)
  # end
end