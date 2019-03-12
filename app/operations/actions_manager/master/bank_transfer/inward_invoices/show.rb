class ActionsManager::Master::BankTransfer::InwardInvoices::Show < ActionsManager::Master::Base

  register_handle :inward_invoices_show
  register_actions [:view_payments, :update_invoice, :make_payment, :delete_invoice]

  def initialize(user=nil, params={})
    super
    result = BankTransfer::InwardInvoices::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.invoice = result.invoice
  end

  def view_payments
    true
  end

  def update_invoice
    (user.has_policy_role?(UserRole.id_for(:invoice_initiator)) || user.has_policy_role?(UserRole.id_for(:invoice_reviewer)) || user.vendor_payments_admin?) && invoice.processing? 
  end

  def make_payment
    user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor))
  end

  def delete_invoice
    (invoice.open? && user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator)))
  end

end