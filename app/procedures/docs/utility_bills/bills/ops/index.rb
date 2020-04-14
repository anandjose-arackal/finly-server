class Docs::UtilityBills::Bills::Ops::Index < Transactions::API
  include HasScope

  has_scope :filter_search
  has_scope :filter_status

  has_scope :filter_department_id
  has_scope :filter_cost_center_id
  has_scope :filter_location_id
  has_scope :filter_policy_id
  has_scope :filter_subscription_id

  has_scope :filter_biller_id
  has_scope :filter_biller_type
  has_scope :filter_poc_id

  has_scope :filter_bill_date, using: [:from, :to], type: :hash
  has_scope :filter_created_on_date, using: [:from, :to], type: :hash
  has_scope :filter_approved_on_date, using: [:from, :to], type: :hash
  has_scope :filter_due_date, using: [:from, :to], type: :hash
  has_scope :filter_paid_on_date, using: [:from, :to], type: :hash
  has_scope :filter_amount, using: [:gteq, :lteq], type: :hash
  has_scope :filter_creation_date, using: [:from, :to]

  has_scope :filter_payable_bills
  has_scope :filter_ids, type: :array
  has_scope :filter_user_id
  has_scope :filter_poc_awaiting_action
  has_scope :filter_overdue


  step Policy::Pundit(Docs::UtilityBills::Bills::Authorizer, :index?)
  # step Resolver::Transactions::Load(model: BbpsBills)
  step :index!

  def index!(options, params:, current_user:, **)
    if current_user.vendor_payment_admin?
      bbps_bills = BbpsBill.role_based_admin_associated_items(current_user, UserRole.id_for(:admin)).or(current_user.bbps_bills)
    elsif current_user.policy_user_roles.pluck(:user_role_id).uniq.present?
      bbps_bills = BbpsBill.associated_items(current_user, ::BbpsBill.roles) || BbpsBill.none
    else
      bbps_bills = BbpsBill.none
    end

    page = params[:page] || 1
    per_page = params[:per_page] || 30

    bbps_bills = apply_scopes(bbps_bills, params)
    result = {
        "bills" => bbps_bills,
        "paginated_bills" => bbps_bills.paginate(page: page, per_page: per_page).includes_for_index
    }

    options['result'] = result
  end
end