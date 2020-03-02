class ActionsManager::Master::Bbps::Bills::Index < ActionsManager::Master::Base

  register_handle :bbps_bills_index
  register_actions [:export, :bulk_approve, :bulk_reject, :bulk_take_control, :bulk_return_control]

  # def create
  #   user.has_policy_role?(UserRole.id_for(:utility_bill_initiator))
  # end

  def export
    false
  end

  def bulk_approve
    user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) || user.vendor_payment_admin?
  end

  def bulk_reject
    user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) || user.vendor_payment_admin?
  end

  def bulk_take_control
    user.vendor_payment_admin?
  end

  def bulk_return_control
    user.vendor_payment_admin?
  end
end