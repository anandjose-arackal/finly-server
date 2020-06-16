class CreditNoteExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :procurement_id, record_attribute: true
  attribute :vendor, record_attribute: true, exposure: true
  attribute :credit_note_id, record_attribute: :sequence_id
  attribute :created_by, record_attribute: true, exposure: true
  attribute :status, record_attribute: true, exposure: true
  attribute :credit_note_date, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :narration, record_attribute: true
  attribute :cost_center, record_attribute: true, exposure: true
  attribute :department, record_attribute: true, exposure: true
  attribute :billing_location, record_attribute: true, exposure: true
  attribute :shipping_location, record_attribute: true, exposure: true
  attribute :policy, record_attribute: true, exposure: true
  attribute :gross_receivable_amount, record_attribute: true, exposure: true
  attribute :tax_amount, record_attribute: true, exposure: true
  attribute :discount_amount, record_attribute: true, exposure: true
  attribute :net_receivable_amount, record_attribute: true, exposure: true
  attribute :tds_rate, record_attribute: true, exposure: true
  attribute :tds_amount, record_attribute: true, exposure: true
  attribute :freight_amount, record_attribute: true, exposure: true
  attribute :previously_adjusted_amount, record_attribute: true, exposure: true
  attribute :net_adjustable_amount, record_attribute: true, exposure: true
  attribute :invoice, record_attribute: true, exposure: true

end