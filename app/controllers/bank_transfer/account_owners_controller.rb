class BankTransfer::AccountOwnersController < ApplicationController

  before_action {finly_authorize! :web}

  def index
    @result = BankTransfer::AccountOwners::Index.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::AccountOwners::Count.(current_user, params)
    render json: @result.as_json
  end


end
