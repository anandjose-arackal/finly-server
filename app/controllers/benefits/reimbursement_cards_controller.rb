class Benefits::ReimbursementCardsController < Benefits::BaseController
  protected
  def cards_config
    PaymentOrder::CONFIG[:reimbursement_card]
  end
end
