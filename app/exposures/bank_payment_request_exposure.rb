class BankPaymentRequestExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :payment_ticket_id, record_attribute: :id
  attribute :payment_order, record_attribute: true, exposure: true, includes: [:payment_order]
  attribute :created_by, record_attribute: true, exposure: true, includes: [:created_by]
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :policy, record_attribute: true, exposure: true, includes: [:policy]
  attribute :status, record_attribute: true, exposure: true, includes: [:status]
  attribute :reviewal_progress, record_attribute: true, includes: [:dlrms]
  attribute :controlling_user, record_attribute: true, exposure: true, includes: [:controlling_user]
  attribute :controlling_level, record_attribute: true, exposure: true, includes: [:controlling_level]
  attribute :payment_mode, record_attribute: true
  attribute :payments, includes: [:payments] do
    record.payment_order.payments.map(&:to_exposure)
  end

end