class PaymentAgreements::Destroy < PaymentAgreements::Base
  
  attr_accessor :payment_agreement

  def init
    self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement
  end

  def authorize
    unless payment_agreement.present? && (payment_agreement.company_id == user.company_id)
      add_message :error, 'Unable to delete'
      return
    end
  end

  def process
    unless payment_agreement.destroy
      add_message :error, "Some error occurred, unable to delete"
      return
    end
  end

  def post_process
    add_message :success, 'Agreement deleted!'
  end

end