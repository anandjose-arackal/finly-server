class ActionsManager::Master::BankTransfer::PaymentRequest::Show < ActionsManager::Master::Base

  register_handle :payment_request_show

  register_actions [ :mark_as_credited, :delete, :submit, :credit, :credit_options, :add_payments, :edit_order_summary, :download_payments_file, :payments_history, :edit_payment_history, :delete_payment_history, :attachments_editable ]


  def mark_as_credited
    user.admin?
  end

  def delete
    user.admin?
  end

  def submit
    user.admin?
  end

  def credit
    user.admin?
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
  
end