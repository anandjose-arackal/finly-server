class Bbps::BillsController < BaseControllers::WebBase
  layout :resolve_layout

  def edit_config
    @op = Docs::UtilityBills::Bills::Configs::Edit.(params.to_unsafe_h, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def filters_config
    @op = Docs::UtilityBills::Bills::Configs::Filters.(params.to_unsafe_h, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def update
    @op = Docs::UtilityBills::Bills::Ops::Update.(params.to_unsafe_h, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def index
    @op = Docs::UtilityBills::Bills::Ops::Index.(params.to_unsafe_h, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def payable_bills
    params[:filter_status] = 'payables'
    @op = Docs::UtilityBills::Bills::Ops::Index.(params.to_unsafe_h, "current_user" => current_user)
    respond_to do |format|
      format.json {render :index}
    end
  end

  def show
    @op = Docs::UtilityBills::Bills::Ops::Show.(params.to_unsafe_h, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def review
    params[:aasm_event] = params[:type]
    @op = Docs::UtilityBills::Bills::Ops::Review.(params.to_unsafe_h, "current_user" => current_user)
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