class AuditTrailExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :item_type, record_attribute: true
  attribute :item_id, record_attribute: true
  attribute :user_id, record_attribute: :whodunnit
  attribute :event, record_attribute: true
  attribute :user_ip, record_attribute: true
  attribute :user_agent, record_attribute: true
  attribute :company_id, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :changes do
    record.change_set.to_s
  end
end