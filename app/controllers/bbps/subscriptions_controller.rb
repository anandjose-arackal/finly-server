class Bbps::SubscriptionsController < BaseControllers::WebBase
  layout 'trailblazers'

  def edit_config
    @result = Docs::UtilityBills::Subscriptions::Configs::Edit.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def fields_config
    @result = Docs::UtilityBills::Subscriptions::Configs::Fields.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def create
    @result = Docs::UtilityBills::Subscriptions::Ops::Create.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def update
    @result = Docs::UtilityBills::Subscriptions::Ops::Update.(params, "current_user" => current_user)
  end

  def index
    @result = Docs::UtilityBills::Subscriptions::Ops::Index.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end
end