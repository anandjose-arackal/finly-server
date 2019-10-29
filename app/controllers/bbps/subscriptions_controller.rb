class Bbps::SubscriptionsController < BaseControllers::WebBase
  layout 'trailblazers'

  def create
    @result = Docs::UtilityBills::Subscriptions::Ops::Create.(params, "current_user" => current_user)
    respond
  end

  def update
    @result = Docs::UtilityBills::Subscriptions::Ops::Update.(params, "current_user" => current_user)
    debugger
  end

  def index
    @result = Docs::UtilityBills::Subscriptions::Ops::Index.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end
end