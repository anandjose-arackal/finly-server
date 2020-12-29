class PurchaseOrderExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :procurement_id, record_attribute: true
  attribute :name, includes: [:procurement] do
    record.procurement&.name
  end
  attribute :po_number, record_attribute: true
  attribute :company, record_attribute: true, exposure: true, includes: [:company]
  attribute :gstin_location, record_attribute: true, exposure: true, includes: [:gstin_location]
  attribute :vendor_location, record_attribute: true, exposure: true, includes: [:vendor_location]
  attribute :vendor, record_attribute: true, exposure: true, includes: [:vendor]
  attribute :review_progress, record_attribute: true, includes: [:dlrms]
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :expected_delivery_date, record_attribute: :delivery_date
  attribute :days_from_approval do
    next unless record.approved_at.present?

    days = Date.today - record.approved_at
    next unless days >= 0

    days
  end
  attribute :policy, exposure: true, record_attribute: true, includes: [:policy]
  attribute :controlling_level, record_attribute: true, exposure: true, includes: [:controlling_level]
  attribute :cost_center, record_attribute: true, exposure: true, includes: [:cost_center]
  attribute :department, record_attribute: true, exposure: true, includes: [:department]
  attribute :sub_department, record_attribute: true, exposure: true, includes: [:sub_department]
  attribute :billing_location, record_attribute: :location, exposure: true, includes: [:location]
  attribute :shipping_location, record_attribute: :delivery_location, exposure: true, includes: [:delivery_location]
  attribute :note, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :gross_amount, record_attribute: true, exposure: true, includes: [:gross_amount]
  attribute :gross_amount_value, includes: [:gross_amount] do
    record.gross_amount&.value || 0
  end
  attribute :discount_amount, record_attribute: true, exposure: true, includes: [:discount_amount]
  attribute :discount_amount_value, includes: [:discount_amount] do
    record.discount_amount&.value || 0
  end
  attribute :tax_amount, record_attribute: true, exposure: true, includes: [:tax_amount]
  attribute :tax_type, record_attribute: true, exposure: true
  attribute :tax_type_name do
    case record.gst_type_id
    when GstType.id_for(:cgst_sgst)
      'CGST + IGST'
    when GstType.id_for(:igst)
      'IGST'
    else
      nil
    end
  end
  attribute :cgst_amount, includes: [:tax_amount] do
    case record.gst_type_id
    when GstType.id_for(:cgst_sgst)
      (tax_amount&.value || 0) / 2
    when GstType.id_for(:igst)
      0
    else
      0
    end
  end
  attribute :sgst_amount, includes: [:tax_amount] do
    cgst_amount
  end
  attribute :igst_amount, includes: [:tax_amount] do
    case record.gst_type_id
    when GstType.id_for(:cgst_sgst)
      0
    when GstType.id_for(:igst)
      tax_amount&.value || 0
    else
      0
    end
  end
  attribute :net_amount, record_attribute: true, exposure: true, includes: [:net_amount]
  attribute :net_amount_value, includes: [:net_amount] do
    record.net_amount&.value || 0
  end
  attribute :roundoff_amount, record_attribute: true

  attribute :balance_amount, record_attribute: true
  # # Fixme: Performance incase the number of line items it high

  attribute :requested_advance_amount, record_attribute: true, exposure: true
  attribute :advance_amount, record_attribute: true, exposure: true
  attribute :advance_tds_amount, record_attribute: true, exposure: true
  attribute :advance_tds_slab, record_attribute: true, exposure: true
  attribute :advance_amount_status, record_attribute: true, exposure: true
  attribute :line_items, record_attribute: :items, exposure: true, includes: [:items]
  attribute :cost_allocation_items, record_attribute: true
  attribute :status, record_attribute: true, exposure: true, includes: [:status]

  attribute :get_reviewers_names do 
    # TODO: having includes for attribute is not useful since we are doing additional query in the following. Update the following to not make addition query
    record.get_reviewers&.map(&:name)&.join(", ")
  end

  attribute :approved_reviewers_names, includes: [{ dlrms: :reviewer }] do
    # TODO: having includes for attribute is not useful since we are doing where query in the following. Update the following to not make addition query
    record.dlrms&.where(action_id: TrailAction.id_for(:approve))&.includes(:reviewer)&.map {|dlr| dlr.reviewer.name}&.join(" ,")
  end

  attribute :purchase_request, exposure: true, includes: [{purchase_request_items: :purchase_request}] do
    record.purchase_request_items.first&.purchase_request
  end

  attribute :payment_term, exposure: true, record_attribute: true

  attribute :closed_at, includes: [:trails] do
    # TODO: having includes for attribute is not useful since we are doing find_by query in the following. Update the following to not make addition query
    record.trails&.find_by(action_id: TrailAction.id_for(:close))&.created_at
  end

  # attribute :submitted_at do
  #   record.trails&.where(action_id: TrailAction.id_for(:submit))&.last&.created_at
  # end

  attribute :delivery_date, record_attribute: true

  attribute :is_approved do
    PurchaseOrderStatus.ids_for(:approved, :auto_approved, :closed, :sent_to_vendor, :vendor_confirmed).include?(record&.purchase_order_status_id)
  end

  attribute :total_before_tax, record_attribute: true, exposure: true

  attribute :invoice, exposure: true, includes: [{procurement: {invoices: [:tax_amount, :net_amount, :discount_amount, :tds_amount, :tds_slab]}}] do
    record.procurement.invoices&.first
  end

  attribute :user, exposure: true, record_attribute: true
  attribute :billing_address, record_attribute: true
  attribute :shipping_address, record_attribute: true
end
