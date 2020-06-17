class Docs::UtilityBills::Subscriptions::Resolver < Resolver::API

  entity BbpsBill

  def load(params)
    if user.vendor_payment_admin?
      admin_restricted_status_ids = [BbpsBillerSubscriptionStatus.id_for(:draft)]
      subscriptions = BbpsBillerSubscription.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).or(user.bbps_subscriptions)
    elsif user.policy_user_roles.pluck(:user_role_id).uniq.present?
      subscriptions = BbpsBillerSubscription.associated_items(user, BbpsBillerSubscription.roles) || BbpsBillerSubscription.none
    else
      subscriptions = BbpsBillerSubscription.none
    end

    return subscriptions unless subscriptions.nil?

    BbpsBillerSubscription.none
  end


end