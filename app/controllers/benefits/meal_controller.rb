class Benefits::MealController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def create
    @result = Benefits::TaxBenefits::Create.(PaymentOrder::CONFIG[:meal_card], current_user, params)
    respond
  end

  def index

  end

  def show

  end

  def process_file
    @result = Benefits::TaxBenefits::ParseFile.(PaymentOrder::CONFIG[:meal_card], current_user, params)
    respond
  end

end
