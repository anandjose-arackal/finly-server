class Benefits::MedicalCardsController < Benefits::BaseController

  protected
  def cards_config
    PaymentOrder::CONFIG[:medical_card]
  end

end
