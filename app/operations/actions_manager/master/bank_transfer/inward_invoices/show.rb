class ActionsManager::Master::BankTransfer::InwardInvoices::Show < ActionsManager::Master::Base

  register_handle :inward_invoices_show
  register_actions [:view_payments, :update_invoice, :make_payment, :delete_invoice]

  def view_payments
    true
  end

  def update_invoice
    true
  end

  def make_payment
    true
  end

  def delete_invoice
    true
  end

end