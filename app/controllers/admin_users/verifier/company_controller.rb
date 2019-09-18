class AdminUsers::Verifier::CompanyController < BaseControllers::AdminBase


  def index
    @result = Admin::Verifier::CompanyIndex.(current_user, params)
    respond
  end

  def history_index
    @result = Admin::Verifier::CompanyHistoricalIndex.(current_user, params)
    respond
  end

end
