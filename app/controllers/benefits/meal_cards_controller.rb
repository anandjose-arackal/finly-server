class Benefits::MealCardsController < Benefits::BaseController

  protected
  def config
    PaymentOrder::CONFIG[:meal_card]
  end

end
