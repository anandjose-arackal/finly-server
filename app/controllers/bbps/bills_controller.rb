class Bbps::BillsController < BaseControllers::WebBase
  layout :resolve_layout

  def edit_config
    endpoint Docs::UtilityBills::Bills::Configs::Edit
    respond_to do |format|
      format.json {}
    end
  end

  def filters_config
    endpoint Docs::UtilityBills::Bills::Configs::Filters
    respond_to do |format|
      format.json {}
    end
  end

  def update
    endpoint Docs::UtilityBills::Bills::Ops::Update
    respond_to do |format|
      format.json {}
    end
  end

  def index
    endpoint Docs::UtilityBills::Bills::Ops::Index
    respond_to do |format|
      format.json {}
    end
  end

  def payable_bills
    params[:filter_status] = 'payables'
    endpoint Docs::UtilityBills::Bills::Ops::Index
    respond_to do |format|
      format.json {render :index}
    end
  end

  def show
    endpoint Docs::UtilityBills::Bills::Ops::Show
    respond_to do |format|
      format.json {}
    end
  end

  def review
    params[:aasm_event] = params[:type]
    endpoint Docs::UtilityBills::Bills::Ops::Review
    respond_to do |format|
      format.json {}
    end
  end

  def actions_config
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

  def destroy
    endpoint Docs::UtilityBills::Bills::Ops::Destroy
    respond_to do |format|
      format.json {}
    end
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