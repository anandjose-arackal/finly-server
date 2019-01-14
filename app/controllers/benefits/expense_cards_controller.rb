class Benefits::ExpenseCardsController < Benefits::BaseController
  protected
  def config
    PaymentOrder::CONFIG[:expense_card]
  end
end
