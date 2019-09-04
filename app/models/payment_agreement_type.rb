class PaymentAgreementType < ApplicationRecord
  
  include Seedable

  def self.values
    [
      :general_invoice,
      :rental_invoice,
      :security_deposit,
      :beneficiary_payment
    ]
  end
end
