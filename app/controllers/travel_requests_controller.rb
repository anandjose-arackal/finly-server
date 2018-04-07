class TravelRequestsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def index
    @result = TravelRequest::Index.(current_user, params)
    respond
  end

  def create
    @result = TravelRequest::Create.(current_user, params)
  end

  def update
    @result = TravelRequest::Update.(current_user, params)
  end

end
