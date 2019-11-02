class Bbps::SubscriptionsController < BaseControllers::WebBase
  layout 'trailblazers'

  def edit_config
    @op = Docs::UtilityBills::Subscriptions::Configs::Edit.(params, "current_user" => current_user)
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