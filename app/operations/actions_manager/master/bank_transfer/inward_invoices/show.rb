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
    (user.vendor_payments_initiator? || user.vendor_payments_reviewer? || user.vendor_payments_admin?) && invoice.processing? 
  end

  def make_payment
    user.vendor_payments_creditor?
  end

  def delete_invoice
    (invoice.open? && user.vendor_payments_initiator?)
  end

end