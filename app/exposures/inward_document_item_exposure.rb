class InwardDocumentItemExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :inward_document, record_attribute: true, exposure: true
  attribute :purchase_order, record_attribute: true, exposure: true
  attribute :inventory_line_item, record_attribute: true, exposure: true
  attribute :product_id, record_attribute: true
  attribute :description, record_attribute: true
  attribute :quantity, record_attribute: true
  attribute :delivered, record_attribute: true
  attribute :accepted, record_attribute: true
  attribute :rejected, record_attribute: true
  attribute :comment, record_attribute: true
  attribute :previously_delivered, record_attribute: true
  attribute :billable_amount, record_attribute: true
  attribute :order_amount, record_attribute: true
  attribute :previously_billed_amount, record_attribute: true
  attribute :product_type_id, record_attribute: true
end