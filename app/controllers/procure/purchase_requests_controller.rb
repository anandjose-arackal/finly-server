class Procure::PurchaseRequestsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def index
    @result = Procurements::PurchaseRequests::Index.(current_user, params)
    respond
  end

  def show
    @result = Procurements::PurchaseRequests::Show.(current_user, params)
    respond
  end

  def create
    @result = Procurements::PurchaseRequests::Create.(current_user, params)
    respond
  end

  def update
    @result = Procurements::PurchaseRequests::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::PurchaseRequests::Destroy.(current_user, params)
    respond
  end

  def edit_config
    @result = Procurements::PurchaseRequests::PurchaseRequestEditConfig.(current_user, params)
    respond
  end

  def actions_configuration
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

end