class CardTransactionsController < BaseControllers::WebBase




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
    @result = Card::Transaction::Refunds.(current_user, params)
    respond
    # params[:filter_refunds] = '1'
    # @result = Card::Transaction::Index.(current_user, params)
    # respond
  end

  def atm_withdrawals
    params[:filter_atm_withdrawals] = '1'
    @result = Card::Transaction::Index.(current_user, params)
    respond
  end

end
