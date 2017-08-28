class BankTransfer::UsersController < ApplicationController

  def index
    @result = BankTransfer::Users::Index.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::Users::Count.(current_user, params)
    render json: @result.as_json
  end

  def show
    @result = BankTransfer::Users::Show.(current_user, params)
    respond
  end

end