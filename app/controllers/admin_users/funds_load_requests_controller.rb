class AdminUsers::FundsLoadRequestsController < BaseControllers::AdminBase
  before_action -> { finly_authorize! :admin}

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

  def reject
    @result = Admin::FundsLoadRequests::Reject.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end
