class AdminUsers::CardAssignRequestsController < ApplicationController

  before_action -> { doorkeeper_authorize! :admin }

  # def company_index
  #   @result = Admin::Cards::AssignRequests::CompanyIndex.(current_user, params)
  #   respond
  # end

  def index
    @result = Admin::Cards::AssignRequests::Index.(current_user, params)
    respond
  end

  def approve
    @result = Admin::Cards::AssignRequests::Approve.(current_user, params)
    respond
  end

  def reject
    @result = Admin::Cards::AssignRequests::Reject.(current_user, params)
    respond
  end

  def mark_as_assigned
    @result = Admin::Cards::AssignRequests::MarkAsAssigned.(current_user, params)
    respond
  end

  def mark_as_assigned_upgraded
    @result = Admin::Cards::AssignRequests::MarkAsAssigned.(current_user, params)
    respond
  end

end
