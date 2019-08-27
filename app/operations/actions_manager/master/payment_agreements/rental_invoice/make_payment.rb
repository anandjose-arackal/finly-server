class ActionsManager::Master::PaymentAgreements::RentalInvoice::MakePayment < ActionsManager::Master::Base

  register_handle :rental_invoice_make_payment
  register_actions [:make_payment]

  def initialize(user=nil, params=nil)
    super
    result = ::PaymentAgreements::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.rental_invoice = result.rental_invoices.find_by_id(params[:invoice_id])
    if rental_invoice.blank?
      add_message :error, 'Rental invoice not found'
      return
    end
  end

  def make_payment
    return false
    # unless agreement.no_expiration
    #   if rental_invoice.payment_agreement.expiration_date.to_date < Date.today
    #     return false
    #   end
    # end
    # if rental_invoice.end_date.to_date >= Date.today
    #   return true
    # end

  end

  def agreement
    self.rental_invoice.payment_agreement
  end

end