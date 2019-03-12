class VendorsController < ApplicationController
  before_action -> { finly_authorize! :web } 

  def submit
    @result = Vendors::Submit.(current_user, params)
    respond
  end

  def retract
    @result = Vendors::Retract.(current_user, params)
    respond
  end

  def reject
    @result = Vendors::Reject.(current_user, params)
    respond
  end

  def approve
    @result = Vendors::Approve.(current_user, params)
    respond
  end

  def take_control
    @result = Vendors::TakeControl.(current_user, params)
    respond
  end

  def return_control
    @result = Vendors::ReturnControl.(current_user, params)
    respond
  end
end