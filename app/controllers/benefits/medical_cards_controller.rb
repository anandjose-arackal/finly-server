class Benefits::MedicalCardsController < Benefits::BaseController

  protected
  def config
    PaymentOrder::CONFIG[:medical_card]
  end

end
