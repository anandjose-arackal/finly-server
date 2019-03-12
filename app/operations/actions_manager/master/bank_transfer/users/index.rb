class ActionsManager::Master::BankTransfer::Users::Index < ActionsManager::Master::Base

  register_handle :users_index
  register_actions [:add_users]

  def add_users
    # Available for all roles expcept for auditor
    # user.vendor_payments_admin? || user.vendor_payments_creditor? || user.vendor_payment_reviewer? || user.vendor_payments_initiator?
    user.has_policy_role?(UserRole.id_for(:admin)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) || user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator))
  end
  
end