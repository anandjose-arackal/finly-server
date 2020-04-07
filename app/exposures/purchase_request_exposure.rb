class PurchaseRequestExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :request_id do
    record.order_number
  end
  attribute :description, record_attribute: true
  attribute :status, exposure: true, record_attribute: true
  attribute :department, exposure: true, record_attribute: true
  attribute :location, exposure: true, record_attribute: true
  attribute :cost_center, exposure: true, record_attribute: true
  attribute :total_amount, exposure: true, record_attribute: true
  attribute :created_by do
    record.creator.to_exposure
  end
  attribute :policy, exposure: true, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :items do
    record.items.map(&:to_exposure)
  end
  attribute :controlling_level, record_attribute: true, exposure: true

end