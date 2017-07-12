class AdminUsers::CardAssignRequestsController < ApplicationController

  before_action -> { doorkeeper_authorize! :admin }

  def company_index
    @result = Admin::Cards::AssignRequests::CompanyIndex.(current_user, params)
    respond
  end

  def index
    @result = Admin::Cards::AssignRequests::Index.(current_user, params)
    respond
  end

  def approve

  end

  def reject

  end

  def mark_as_assigned

  end

  def mark_as_assigned_upgraded

  end

end
