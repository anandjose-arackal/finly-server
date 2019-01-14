# this controller will be the one serving all the external links for payment receivables and invoices
class Invoicing::PublicLinksController < BaseControllers::PublicBase

  def payment_receivable_show
    @result = Invoicing::PaymentReceivable::Public::Show.(current_user, params)
    respond
  end

  def virtual_bank_account_show
    @result = Invoicing::VirtualBankAccount::Public::Show.(current_user, params)
    respond
  end

  def invoice_show
    @result = Invoicing::Invoice::Public::Show.(current_user, params)
    respond
  end
end
