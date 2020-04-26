class PaymentAgreementExposure < Exposures::API

  attribute :policy, record_attribute: true, exposure: true
  attribute :agreement_number, record_attribute: :get_agreement_number
  attribute :agreement_date, record_attribute: true
  attribute :execution_date, record_attribute: true
  attribute :expiration_date, record_attribute: true

end