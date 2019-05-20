class ActionsManager::Master::PaymentAgreements::Index < ActionsManager::Master::Base

  register_handle :payment_agreement_index
  register_actions [:create_payment_agreement]

  def create_payment_agreement
    true
  end

end