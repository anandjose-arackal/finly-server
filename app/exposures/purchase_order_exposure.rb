class PurchaseOrderExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :procurement_id, record_attribute: true
  attribute :name do
    record.procurement&.name
  end
  attribute :po_number, record_attribute: true
  attribute :company, record_attribute: true, exposure: true, includes: [:company]
  attribute :gstin_location, record_attribute: true, exposure: true, includes: [:gstin_location]
  attribute :vendor_location, record_attribute: true, exposure: true, includes: [:vendor_location]
  attribute :vendor, record_attribute: true, exposure: true, includes: [:vendor]
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :days_from_approval do
    next unless record.approved_at.present?

    days = Date.today - record.approved_at
    next unless days >= 0

    days
  end
  attribute :policy, exposure: true, record_attribute: true, includes: [:policy]
  attribute :controlling_user, exposure: true, includes: [:controlling_user] do
    next if record.controlling_level_id.blank?

    record.controlling_user
  end
  attribute :controlling_level, record_attribute: true, includes: [:controlling_level]
  attribute :cost_center, record_attribute: true, exposure: true, includes: [:cost_center]
  attribute :department, record_attribute: true, exposure: true, includes: [:department]
  attribute :billing_location, record_attribute: :location, exposure: true, includes: [:location]
  attribute :shipping_location, record_attribute: :delivery_location, exposure: true, includes: [:delivery_location]
  attribute :note, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :gross_amount, record_attribute: true, exposure: true, includes: [:total_before_tax]
  attribute :gross_amount_value, includes: [:gross_amount] do
    record.total_before_tax&.value || 0
  end
  attribute :net_amount, record_attribute: true, exposure: true, includes: [:balance_amount]
  attribute :net_amount_value, includes: [:net_amont] do
    record.balance_amount&.value || 0
  end
  attribute :discount_amount, record_attribute: true, exposure: true, includes: [:discount_amount]
  attribute :discount_amount_value, includes: [:discount_amount] do
    record.discount_amount&.value || 0
  end
  attribute :roundoff_amount, record_attribute: true
  # # Fixme: Performance incase the number of line items it high
  attribute :line_items, record_attribute: :items, exposure: true, includes: [:items]
  attribute :cost_allocation_items, record_attribute: true
  attribute :status, record_attribute: true, exposure: true, includes: [:status]
  attribute :tax_type, record_attribute: true, exposure: true
  attribute :tax_type_name do
    case record.tax_type_id
    when GstType.id_for(:cgst_sgst)
      'CGST + IGST'
    when GstType.id_for(:igst)
      'IGST'
    else
      nil
    end
  end

end