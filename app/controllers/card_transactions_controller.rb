class CardTransactionsController < ApplicationController

  before_action :authenticate_user!

  allow_oauth!

  def index
    @result = Card::Transaction::Index.(current_user, params)
    respond
  end

  def create

  end

  def cancelled_transactions
    @result = Expense::Cancelled::CancelledTransactions.(current_user, params)
    respond
  end

  def refunds
    params[:filter_refunds] = '1'
    @result = Card::Transaction::Index.(current_user, params)
    respond
  end

  def atm_withdrawals
    params[:refunds] = '1'
    @result = Card::Transaction::Index.(current_user, params)
    respond
  end

end