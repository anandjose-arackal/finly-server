class Docs::P2P::Inwards::Received::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions :goods_receiver, :admin
  resolver 'inward_documents.received'
  reference '{{record.id}}', procurement_id: '{{record.procurement_id}}', document_type: "inward_document"
  selectable false

  # Fixed column is always default true
  column :vendor, label: 'Vendor Details', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: "{{record.vendor.business_name}}", format: 'primary'
    text value: "Vendor ID: {{record.vendor.vendor_id}}"
  end

  column :receipt_note_number, label: 'Receipt Note Number', default: true do
    text value: '{{record.receipt_note_number}}', format: 'primary'
  end

  column :name, label: "Name", default: true, includes: [:purchase_order] do
    text value: '{{record.purchase_order.name}}'
  end

  column :po_number, sort: :po_number, label: "PO Number", default: true, includes: [:purchase_order] do
    text value: '{{record.purchase_order.po_number}}'
  end

  column :expected_delivery_on, sort: :purchase_order_delivery_date, includes: [:purchase_order] do
    date value: "{{record.purchase_order.expected_delivery_date}}"
  end

  column :delivered_on, sort: :delivery_date, default: true do
    date value: :delivery_date
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :created_on, sort: :created_at, default: true do
    date value: :created_at
  end

  column :grn_number, label: "Reference Number", default: true, sort: :grn_number do
    text value: :grn_number
  end

  column :cost_center, default: true, includes: [purchase_order: :cost_center] do
    text value: :cost_center_name
  end

  column :department, default: true, includes: [purchase_order: :department] do
    text value: :department_name
  end

  column :vendor_location, default: false, includes: [purchase_order: :gstin_location] do
    text value: "{{record.purchase_order.gstin_location.location}}"
  end

  column :billing_location, sort: :billing_location_name, default: false, includes: [purchase_order: :location] do
    text value: "{{record.purchase_order.billing_location.name}}"
  end

  column :shipping_location, sort: :shipping_location_name, default: true, includes: [purchase_order: :delivery_location] do
    text value: "{{record.purchase_order.shipping_location.name}}"
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_grn_status_id
    counter.add nil, "All", collection.count
    counter
  end

  def self.cost_center_name(context)
    return "Multiple" if context[:record].purchase_order&.cost_allocation_items

    context[:record].purchase_order&.cost_center&.name
  end

  def self.department_name(context)
    return "Multiple" if context[:record].purchase_order&.cost_allocation_items

    context[:record].purchase_order&.department&.name
  end

end