class InwardDocumentExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :delivery_date, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :deleted_at, record_attribute: true
  attribute :grn_number, record_attribute: true
  attribute :receipt_note_number, record_attribute: :doc_number
  attribute :purchase_order, record_attribute: true, exposure: true
  attribute :procurement, record_attribute: true, exposure: true
  attribute :vendor, record_attribute: true, exposure: true

end