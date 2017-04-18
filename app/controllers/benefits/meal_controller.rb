class Benefits::MealController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def process_file
    @result = Benefits::TaxBenefits::ParseFile.(PaymentOrder::CONFIG[:meal_card], current_user, params)
    respond
  end

  def create
    @result = Benefits::TaxBenefits::Create.(PaymentOrder::CONFIG[:meal_card], current_user, params)
    respond
  end

  def update
    @result = Benefits::TaxBenefits::Update.(PaymentOrder::CONFIG[:meal_card], current_user, params)
    if @result.success?
      respond_to do |format|
        format.json { render 'benefits/meal/process_file' }
        format.html {}
      end
      return
    end
    respond
  end

  def index
    @result = Benefits::TaxBenefits::Index.(PaymentOrder::CONFIG[:meal_card], current_user, params)
    respond
  end

  def show
    @result = Benefits::TaxBenefits::Show.(PaymentOrder::CONFIG[:meal_card], current_user, params)
    respond
  end

  def destroy
    respond
  end

end
