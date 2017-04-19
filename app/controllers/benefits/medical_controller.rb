class Benefits::MedicalController < Benefits::BaseController

  protected
  def config
    PaymentOrder::CONFIG[:medical_card]
  end

end
