class ActionsManager::Master::PaymentAgreements::Index < ActionsManager::Master::Base

  register_handle :payment_agreement_index
  register_actions [:create_payment_agreement, :bulk_action, :take_control, :bulk_approve, :bulk_reject]

  def create_payment_agreement
    true
  end

  def bulk_action
    true
  end

  def take_control
    true
  end

  def bulk_approve
    true
  end

  def bulk_reject
    true
  end

end