class PurchaseRequestItemExposure < Exposures::API
  attribute :id, record_attribute: true
  attribute :tax_rate, record_attribute: true, exposure: true
  attribute :purchase_request, record_attribute: true, exposure: true
  attribute :item, record_attribute: true, exposure: true
  attribute :vendor, record_attribute: true, exposure: true
  attribute :delivery_location, record_attribute: true, exposure: true
  attribute :purpose, record_attribute: true
  attribute :quantity, record_attribute: true
  attribute :per_unit_estimated_amount, record_attribute: true, exposure: true
  attribute :estimated_amount, record_attribute: true, exposure: true
  attribute :required_by_date, record_attribute: true
  attribute :status, record_attribute: true, exposure: true
  attribute :rejected, record_attribute: true
  attribute :unit_of_measurement, record_attribute: true
  attribute :reject_note, record_attribute: true
  attribute :department, record_attribute: true, exposure: true
  attribute :cost_center, record_attribute: true, exposure: true
  attribute :category, record_attribute: true, exposure: true
  attribute :hsn_sac, record_attribute: true
  attribute :pr_number, exposure: true do
    record.purchase_request&.item&.order_number
  end
end