class ActionsManager::Master::BankTransfer::PaymentRequest::Show < ActionsManager::Master::Base

  register_handle :payment_ticket_show

  register_actions [ :mark_as_credited, :delete, :submit, :credit, :credit_options, :add_payments, :edit_order_summary, :download_payments_file, :payments_history, :edit_payment_history, :delete_payment_history, :attachments_editable, :reject, :retract, :approve, :take_control, :return_control, :unapprove, :cancel_scheduled_payment, :retry_payment ]


  def mark_as_credited
    roles_without_auditor
  end

  def delete
    roles_without_auditor
  end

  def submit
    roles_without_auditor
  end

  def credit
    roles_without_auditor
  end

  def credit_options
    user.admin?
  end

  def add_payments
    user.admin?
  end

  def edit_order_summary
    user.admin?
  end

  def download_payments_file
    user.admin?
  end

  def payments_history
    user.admin?
  end

  def edit_payment_history
    user.admin?
  end

  def delete_payment_history
    user.admin?
  end

  def attachments_editable
    user.admin?
  end

  def reject
    roles_without_auditor
  end

  def retract
    roles_without_auditor
  end

  def approve
    roles_without_auditor
  end
  
  def take_control
    roles_without_auditor
  end

  def return_control
    roles_without_auditor
  end

  def unapprove
    roles_without_auditor
  end

  def cancel_scheduled_payment
    roles_without_auditor
  end

  def retry_payment
    roles_without_auditor
  end

  def roles_without_auditor
    # All user roles expect auditor
    user.vendor_payments_admin? || user.vendor_payments_creditor? || user.vendor_payment_reviewer? || user.vendor_payments_initiator?
  end
end