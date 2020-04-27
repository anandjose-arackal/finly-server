class PaymentAgreementExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :title, record_attribute: true
  attribute :agreement_id, record_attribute: :order_number
  attribute :policy, record_attribute: true, exposure: true
  attribute :agreement_number, record_attribute: :get_agreement_number
  attribute :agreement_date, record_attribute: true
  attribute :execution_date, record_attribute: true
  attribute :expiration_date, record_attribute: true
  attribute :no_expiration, record_attribute: true
  attribute :note, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :status, record_attribute: true, exposure: true
  attribute :total_amount, record_attribute: true, exposure: true

end