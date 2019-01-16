class ActionsManager::Master::BankTransfer::InwardInvoices::Show < ActionsManager::Master::Base

  register_handle :inward_invoices_show

  register_actions [:view_payments, :update_invoice, :make_payment, :delete_invoice]

  def view_payments
    user.admin?
  end

  def update_invoice
    user.admin?
  end

  def make_payment
    user.admin?
  end

  def delete_invoice
    user.admin?
  end

end