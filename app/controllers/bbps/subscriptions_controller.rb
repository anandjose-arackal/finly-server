class Bbps::SubscriptionsController < BaseControllers::WebBase
  layout :resolve_layout

  def edit_config
    endpoint Docs::UtilityBills::Subscriptions::Configs::Edit
    respond_to do |format|
      format.json {}
    end
  end

  def filters_config
    endpoint Docs::UtilityBills::Subscriptions::Configs::Filters
    respond_to do |format|
      format.json {}
    end
  end

  def biller_type_config
    endpoint Docs::UtilityBills::Subscriptions::Configs::BillerType
    respond_to do |format|
      format.json {}
    end
  end

  def biller_field_config
    endpoint Docs::UtilityBills::Subscriptions::Configs::BillerFields
    respond_to do |format|
      format.json {}
    end
  end

  def create
    endpoint Docs::UtilityBills::Subscriptions::Ops::Create
  end

  def validate_customer_params
    endpoint Docs::UtilityBills::Subscriptions::Ops::ValidateCustomerParams
    respond_to do |format|
      format.json {}
    end
  end

  def update
    endpoint Docs::UtilityBills::Subscriptions::Ops::Update
  end

  def index
    endpoint Docs::UtilityBills::Subscriptions::Ops::Index
    respond_to do |format|
      format.json {}
    end
  end

  def show
    endpoint Docs::UtilityBills::Subscriptions::Ops::Show
    respond_to do |format|
      format.json {}
    end
  end

  def fetch_bill
    endpoint Docs::UtilityBills::Subscriptions::Ops::FetchBill
  end

  def update_and_submit
    params[:id] = params[:id] || params[:_id]
    endpoint Docs::UtilityBills::Subscriptions::Ops::UpdateAndSubmit
  end

  def review
    params[:aasm_event] = params[:type]
    endpoint Docs::UtilityBills::Subscriptions::Ops::Review
    respond_to do |format|
      format.json {}
    end
  end

  def destroy
    endpoint Docs::UtilityBills::Subscriptions::Ops::Destroy
    respond_to do |format|
      format.json {}
    end
  end

  def add_bill
    endpoint Docs::UtilityBills::Subscriptions::Ops::AddBill
    respond_to do |format|
      format.json {}
    end
  end

  def actions_config
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

  private

  def resolve_layout
    case action_name
    when 'actions_config'
      'application'
    else
      'trailblazers'
    end
  end
end