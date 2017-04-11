class Benefits::MealController < ApplicationController

  def create

  end

  def index

  end

  def show

  end

  def process_file
    @result = Benefits::TaxBenefits::Meal::ProcessFile.(current_user, params)
    respond
  end

end
