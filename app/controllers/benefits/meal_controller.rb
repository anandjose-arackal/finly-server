class Benefits::MealController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

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
