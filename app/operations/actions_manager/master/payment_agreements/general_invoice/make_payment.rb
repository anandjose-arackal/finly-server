class ActionsManager::Master::PaymentAgreements::GeneralInvoice::MakePayment < ActionsManager::Master::Base

  register_handle :general_invoice_make_payment
  register_actions [:make_payment]

  def initialize(user=nil, params=nil)
    super
    result = ::PaymentAgreements::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.general_invoice = result.general_invoices.find_by_id(params[:invoice_id])
    if general_invoice.blank?
      add_message :error, 'General invoice not found'
      return
    end
  end

  def make_payment
    (general_invoice.end_date.to_date >= Date.today) && (general_invoice.payment_agreement.expiration_date.to_date >= Date.today)
  end

end