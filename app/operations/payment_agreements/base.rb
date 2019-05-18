class PaymentAgreements::Base < BaseOperation

  attr_accessor :company

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters, try again'
      return
    end
  end

  def payment_agreement_parameters
    params.require(:payment_agreement).permit(:id, :title, :policy_id, :agreement_date, :execution_date, :expiration_date, :renewal_date, :note, :no_expiration, :reject_note )
  end

end