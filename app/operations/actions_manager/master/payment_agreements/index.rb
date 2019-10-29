class ActionsManager::Master::PaymentAgreements::Index < ActionsManager::Master::Base

  register_handle :payment_agreement_index
  register_actions [:create_payment_agreement, :export]

  def create_payment_agreement
    user.is_payment_agreement_initiator? || user.vendor_payment_admin?
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

  def export
    true
  end

end