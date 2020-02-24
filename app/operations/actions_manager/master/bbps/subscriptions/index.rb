class ActionsManager::Master::Bbps::Subscriptions::Index < ActionsManager::Master::Base

  register_handle :bbps_subscriptions_index
  register_actions [:create]

  def create
    user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator))
  end

  def bulk_approve
    user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer)) || user.vendor_payment_admin?
  end

  def bulk_reject
    user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer)) || user.vendor_payment_admin?
  end

  def bulk_take_control
    user.vendor_payment_admin?
  end

  def bulk_return_control
    user.vendor_payment_admin?
  end
end