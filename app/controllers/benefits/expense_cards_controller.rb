class Benefits::ExpenseCardsController < Benefits::BaseController
  protected
  def cards_config
    PaymentOrder::CONFIG[:expense_card]
  end
end