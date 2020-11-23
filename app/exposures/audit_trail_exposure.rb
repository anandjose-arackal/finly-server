class AuditTrailExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :item_type, record_attribute: true
  attribute :item_id, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :event, record_attribute: true
  attribute :user_ip, record_attribute: true
  attribute :user_agent, record_attribute: true
  attribute :company_id, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :transaction_id, record_attribute: true
  attribute :changes do
    record.changeset.to_s
  end

  attribute :changes_less do
    record.changes_less
  end
end