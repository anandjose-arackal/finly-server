class Benefits::MealController < Benefits::BaseController

  protected
  def config
    PaymentOrder::CONFIG[:meal_card]
  end

end
