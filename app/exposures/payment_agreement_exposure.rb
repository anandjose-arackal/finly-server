class PaymentAgreementExposure < Exposures::API

  attribute :policy, record_attribute: true, exposure: true
  attribute :agreement_number, record_attribute: true

end