# Execute executes the payment order and is always executed in the background.
# It can only be executed directly from create or from crono
class Benefits::TaxBenefits::Execute < Benefits::TaxBenefits::Base

  def pre_validate
  end

end
