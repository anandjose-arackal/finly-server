class AdminUsers::Kyc::UsersController < ApplicationController

  before_action -> { doorkeeper_authorize! :admin }

  # def company_index
  #   @result = Admin::KycProcesses::Users::CompanyIndex.(current_user, params)
  #   respond
  # end

  def index
    @result = Admin::KycProcesses::Users::Index.(current_user, params)
    respond
  end

  def approve
    @result = Admin::KycProcesses::Users::Approve.(current_user, params)
    respond
  end

  def reject
    @result = Admin::KycProcesses::Users::Reject.(current_user, params)
    respond
  end

  def mark_as_upgraded
    @result = Admin::KycProcesses::Users::MarkAsAssigned.(current_user, params)
    respond
  end

end
