class ActionsManager::Master::BankTransfer::Users::Show < ActionsManager::Master::Base

  register_handle :users_show
  register_actions [:credit, :debit, :edit_policies, :add_bank_accounts, :edit_bank_accounts, :edit_configuration, :edit_permission, :edit_roles, :resend_invite, :delete_invite]

  def credit
    # Available for all user roles except auditor
    user.vendor_payments_admin? || user.vendor_payments_creditor? || user.vendor_payment_reviewer? || user.vendor_payments_initiator?
  end

  def debit
    true
  end

  def edit_policies
    true
  end

  def add_bank_accounts
    true
  end

  def edit_bank_accounts
    true    
  end

  def edit_configuration
    true
  end

  def edit_permission
    true
  end

  def edit_roles
    true
  end

  def resend_invite
    # Available for all user roles
    user.vendor_payments_admin? || user.auditor? || user.vendor_payments_creditor? || user.vendor_payment_reviewer? || user.vendor_payments_initiator?
  end

  def delete_invite
    # Available for all user roles
    user.vendor_payments_admin? || user.auditor? || user.vendor_payments_creditor? || user.vendor_payment_reviewer? || user.vendor_payments_initiator?
  end

end