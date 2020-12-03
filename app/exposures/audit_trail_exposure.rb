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
  attribute :document_number, record_attribute: true
  attribute :parent_document_type, record_attribute: true
  attribute :changes do
    record.get_change_statement
  end

  attribute :changes_less do
    record.changes_less
  end

  attribute :item_type_label do
    "#{record.item_type} Changes"
  end
end