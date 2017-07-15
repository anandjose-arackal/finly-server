class AdminUsers::Verifier::CompanyController < ApplicationController

  before_action -> { doorkeeper_authorize! :admin }

  def index
    @result = Admin::Verifier::CompanyIndex.(current_user, params)
    respond
  end

end
