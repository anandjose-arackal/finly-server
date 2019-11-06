class Docs::UtilityBills::Subscriptions::Ops::Index < Transactions::API
  include HasScope

  has_scope :filter_search
  has_scope :filter_status

  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :index? )
  step Transactions::Resolver::Model(BbpsBillerSubscription)
  step :index!


  def index!(options, params:, current_user:, **)
    if current_user.vendor_payment_admin?
      admin_restricted_status_ids = [BbpsBillerSubscriptionStatus.id_for(:draft)]
      subscriptions = BbpsBillerSubscription.role_based_admin_associated_items(current_user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).or(current_user.bbps_subscriptions)
    elsif user.policy_user_roles.pluck(:user_role_id).uniq.present?
      subscriptions = BbpsBillerSubscription.associated_items(current_user, BbpsBillerSubscription.roles) || BbpsBillerSubscription.none
    else
      subscriptions = BbpsBillerSubscription.none
    end

    page ||= params[:page]
    per_page ||= params[:per_page]

    subscriptions = apply_scopes(subscriptions, params).paginate(page: page, per_page: per_page)
    result = {
        "subscriptions" => BbpsBillerSubscription.includes_for_index
    }

    options['result'] = result
  end
end