class Bbps::SubscriptionsController < BaseControllers::WebBase
  layout :resolve_layout

  def edit_config
    @op = Docs::UtilityBills::Subscriptions::Configs::Edit.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def filters_config
    @op = Docs::UtilityBills::Subscriptions::Configs::Filters.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def biller_type_config
    @op = Docs::UtilityBills::Subscriptions::Configs::BillerType.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def biller_field_config
    @op = Docs::UtilityBills::Subscriptions::Configs::BillerFields.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def create
    @op = Docs::UtilityBills::Subscriptions::Ops::Create.(params, "current_user" => current_user)
    debugger
    respond_to do |format|
      format.json {}
    end
  end

  def validate_customer_params
    @op = Docs::UtilityBills::Subscriptions::Ops::ValidateCustomerParams.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def update
    @op = Docs::UtilityBills::Subscriptions::Ops::Update.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def index
    @op = Docs::UtilityBills::Subscriptions::Ops::Index.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def show
    @op = Docs::UtilityBills::Subscriptions::Ops::Show.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def review
    params[:aasm_event] = params[:type]
    @op = Docs::UtilityBills::Subscriptions::Ops::Review.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def add_bill
    @op = Docs::UtilityBills::Subscriptions::Ops::AddBill.(params, "current_user" => current_user)
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