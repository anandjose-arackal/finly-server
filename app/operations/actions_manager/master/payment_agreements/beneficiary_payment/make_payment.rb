class ActionsManager::Master::PaymentAgreements::BeneficiaryPayment::MakePayment < ActionsManager::Master::Base

  register_handle :beneficiary_payment_make_payment
  register_actions [:make_payment]

  def initialize(user=nil, params=nil)
    super
    result = ::PaymentAgreements::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.beneficiary_payment = result.beneficiary_payments.find_by_id(params[:beneficiary_payment_id])
    if beneficiary_payment.blank?
      add_message :error, 'Beneficiary Payment not found'
      return
    end
  end

  def make_payment
    unless agreement.no_expiration
      return agreement.expiration_date.to_date >= Date.today
    end
    true
  end


  def agreement
    beneficiary_payment.payment_agreement
  end

end