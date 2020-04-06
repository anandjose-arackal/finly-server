class Masters::Vendors::Resolver < Resolver::API

  entity YesBankVendor

  def load(params)
    if user.vendor_payments_admin?
      vendors = ::YesBankVendor.role_based_admin_associated_items(user, UserRole.id_for(:admin)).non_draft.or(user.vendors)
      return vendors
    end

    if user.policy_user_roles.count > 0
      role_based_data = ::YesBankVendor.associated_items(user, ::YesBankVendor.roles) || ::YesBankVendor.none
      vendors = user.company.yes_bank_vendors.approved.or(role_based_data)
    else
      vendors = user.company.yes_bank_vendors.approved
    end

    return vendors unless vendors.nil?
    ::YesBankVendor.none
  end

end