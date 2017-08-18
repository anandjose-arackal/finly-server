class BankTransfer::UsersController < ApplicationController

  def index
    @result = BankTransfer::Users::Index.(current_user, params)
    respond
  end

  def show
    @result = BankTransfer::Users::Show.(current_user, params)
    respond
  end

end