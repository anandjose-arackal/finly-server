class Benefits::TaxBenefits::Meal::Base < Benefits::BaseOperation

  def subscription
    :meal_card_enabled
  end

end