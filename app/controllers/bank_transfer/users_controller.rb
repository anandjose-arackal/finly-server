class BankTransfer::UsersController < ApplicationController

  def index
    @result = BankTransfer::Users::Index.(current_user, params)
    respond
  end

  def show

  end

end