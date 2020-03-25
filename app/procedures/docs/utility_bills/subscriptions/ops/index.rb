class Docs::UtilityBills::Subscriptions::Ops::Index < Transactions::API
  include HasScope

  has_scope :filter_search
  has_scope :filter_status

  has_scope :filter_department_id
  has_scope :filter_cost_center_id
  has_scope :filter_location_id
  has_scope :filter_policy_id
  has_scope :filter_biller_type
  has_scope :filter_biller_id
  has_scope :filter_user_id
  has_scope :filter_ids, type: :array


  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :index? )
  # step Transactions::Resolver::Model(BbpsBillerSubscription, scope: :default, filter: true, paginate: true)
  step :index!

  # def check(options, params:, **)
  # end
  #
  # def check2(options, params:, **)
  # end

  def index!(options, params:, current_user:, **)
    if current_user.vendor_payment_admin?
      admin_restricted_status_ids = [BbpsBillerSubscriptionStatus.id_for(:draft)]
      subscriptions = BbpsBillerSubscription.role_based_admin_associated_items(current_user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).or(current_user.bbps_subscriptions)
    elsif current_user.policy_user_roles.pluck(:user_role_id).uniq.present?
      subscriptions = BbpsBillerSubscription.associated_items(current_user, BbpsBillerSubscription.roles) || BbpsBillerSubscription.none
    else
      subscriptions = BbpsBillerSubscription.none
    end

    page = params[:page] || 1
    per_page = params[:per_page] || 30
    subscriptions = apply_scopes(subscriptions, params)
    result = {
        "subscriptions" => subscriptions.paginate(page: page, per_page: per_page).includes_for_index
    }
    options['result'] = result
  end
end