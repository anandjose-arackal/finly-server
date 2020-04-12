class Docs::UtilityBills::Bills::Resolver < Resolver::API

  entity BbpsBill

  def load(params)
    bbps_bills = nil
    if user.vendor_payment_admin?
      bbps_bills = BbpsBill.role_based_admin_associated_items(user, UserRole.id_for(:admin)).or(user.bbps_bills)
    elsif user.policy_user_roles.pluck(:user_role_id).uniq.present?
      bbps_bills = BbpsBill.associated_items(user, ::BbpsBill.roles) || BbpsBill.none
    else
      bbps_bills = BbpsBill.none
    end

    return bbps_bills unless bbps_bills.nil?

    ::BbpsBill.none
  end


end