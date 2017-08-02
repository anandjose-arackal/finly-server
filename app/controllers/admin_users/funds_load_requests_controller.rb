class AdminUsers::FundsLoadRequestsController < ApplicationController
  before_action -> { doorkeeper_authorize! :admin}

  def index
    @result = Admin::FundsLoadRequests::Index.(current_user, params)
    respond
  end

  def approve
    @result = Admin::FundsLoadRequests::Approve.(current_user, params)
    if @result.failure?
      respond response: :failure
      return
    end
    respond response: :success
  end
end