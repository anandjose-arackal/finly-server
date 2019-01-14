class Benefits::ReimbursementCardsController < Benefits::BaseController
  protected
  def config
    PaymentOrder::CONFIG[:reimbursement_card]
  end
end
