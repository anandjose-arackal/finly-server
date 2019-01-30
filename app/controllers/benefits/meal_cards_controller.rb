class Benefits::MealCardsController < Benefits::BaseController

  protected
  def cards_config
    PaymentOrder::CONFIG[:meal_card]
  end

end
