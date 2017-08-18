class BankAccountsController < ApplicationController
  before_action -> { finly_authorize! :web}

  def index
    @bank_accounts = current_user.bank_accounts
  end
end