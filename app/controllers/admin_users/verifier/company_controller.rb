class AdminUsers::Verifier::CompanyController < ApplicationController

  before_action -> { finly_authorize! :admin }

  def index
    @result = Admin::Verifier::CompanyIndex.(current_user, params)
    respond
  end

  def history_index
    @result = Admin::Verifier::CompanyHistoricalIndex.(current_user, params)
    respond
  end

end
