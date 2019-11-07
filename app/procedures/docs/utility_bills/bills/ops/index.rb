class Docs::UtilityBills::Bills::Ops::Index < Transactions::API
  include HasScope

  has_scope :filter_search
  has_scope :filter_status

  has_scope :filter_department_id
  has_scope :filter_cost_center_id
  has_scope :filter_location_id
  has_scope :filter_policy_id

  has_scope :filter_date


  step Policy::Pundit(Docs::UtilityBills::Bills::Authorizer, :index?)
  # step Transactions::Resolver::Model(BbpsBills)
  step :index!


  def index!(options, params:, current_user:, **)
    if current_user.vendor_payment_admin?
      bbps_bills = BbpsBill.all
    elsif user.policy_user_roles.pluck(:user_role_id).uniq.present?
      bbps_bills = BbpsBill.associated_items(current_user, ::BbpsBill.roles) || BbpsBill.none
    else
      bbps_bills = BbpsBill.none
    end

    page ||= 1
    per_page ||= 30

    bbps_bills = apply_scopes(bbps_bills, params)
    result = {
        "bills" => bbps_bills.paginate(page: page, per_page: per_page).includes_for_index
    }

    options['result'] = result
  end
end