class Docs::P2P::PurchaseOrders::Index < IndexBuilder::API
  include DynamicAttributes

  resolver 'purchase_orders.default'
  reference '{{record.id}}', procurement_id: '{{record.procurement_id}}', procurement_type: 'po'

  # Fixed column is always default true
  column :vendor, label: 'Vendor Details', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: "{{record.vendor.business_name}}", format: 'primary'
    text value: "Vendor ID: {{record.vendor.vendor_id}}"
  end

  column :po_number, sort: :po_number, label: "PO Number", default: true do
    badge value: :po_number, format: "success"
  end

  column :name, label: "Name", default: true do
    text value: "{{record.name}}", format: "success"
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :submitted_at, sort: :submitted_at do
    date value: :submitted_at
  end

  column :approved_at, sort: :approved_at do
    date value: :approved_at
  end

  column :status, default: true, includes: [:status] do
    badge value: :po_status, format: :format_status
  end

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :net_amount, default: true, includes: [net_amount: :currency] do
    amount value: :net_amount
  end

  column :gross_amount, default: true, includes: [gross_amount: :currency] do
    amount value: :gross_amount
  end

  column :cost_center, default: true, includes: [:cost_center] do
    text value: :cost_center_name
  end

  column :department, default: true, includes: [:department] do
    text value: :department_name
  end

  column :vendor_location, default: false, includes: [:gstin_location] do
    text value: "{{record.gstin_location.location}}"
  end

  column :billing_location, sort: :billing_location_name, default: false, includes: [:location] do
    text value: "{{record.billing_location.name}}"
  end

  column :shipping_location, sort: :shipping_location_name, default: false, includes: [:delivery_location] do
    text value: "{{record.shipping_location.name}}"
  end

  column :controlling_user, default: true, includes: [:controlling_user] do
    user value: :controlling_user
  end

  column :controlling_level, default: true, includes: [:controlling_level] do
    text value: "{{record.controlling_level.name}}"
  end

  column :grn_status, default: true, includes: [procurement: [:status_tags]] do
    text value: :grn_status_text
  end

  column :invoice_status, default: true, includes: [procurement: [:status_tags]] do
    text value: :invoice_status_text
  end

  column :payment_status, default: true, includes: [procurement: [:status_tags]] do
    text value: :payment_status_text
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_ids
    counts = collection.group(:purchase_order_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    # Open / Retracted
    counter.add 90, 'Open', (counts[PurchaseOrderStatus.id_for(:open)] + counts[PurchaseOrderStatus.id_for(:retracted)])

    # Awaiting Approval
    if user.has_permission?(awaiting_approval_roles)
      counter.add 91, 'Awaiting Approval',
                  collection.where(purchase_order_status_id: PurchaseOrderStatus.id_for(:processing), controlling_user_id: user.id).count
    end

    counter.add PurchaseOrderStatus.id_for(:processing), "Processing", counts[PurchaseOrderStatus.id_for(:processing)]

    # Approved / Auto Approved
    counter.add 92, 'Approved', (counts[PurchaseOrderStatus.id_for(:approved)] + counts[PurchaseOrderStatus.id_for(:auto_approved)])

    [:rejected, :voided, :sent_to_vendor, :vendor_confirmed, :closed].each do |status|
      counter.add PurchaseOrderStatus.id_for(status), status.to_s.titleize, counts[PurchaseOrderStatus.id_for(status)]
    end

    counter
  end

  def self.awaiting_approval_roles
    [:purchase_order_reviewer, :admin]
  end

  def self.po_status(user, record, record_exposure)
    return 'Awaiting Approval'.upcase if record.purchase_order_status_id == PurchaseOrderStatus.id_for(:processing) and record.controlling_user_id == user.id

    record.status&.name&.humanize&.upcase
  end

  def self.cost_center_name(user, record, record_exposure)
    return "Multiple" if record_exposure.cost_allocation_items

    record_exposure.cost_center&.name
  end

  def self.department_name(user, record, record_exposure)
    return "Multiple" if record_exposure.cost_allocation_items

    record_exposure.department&.name
  end

  def self.grn_status_text(user, record, record_exposure)
    record.status_tag_details&.dig(:grn, :status_text)
  end

  def self.invoice_status_text(user, record, record_exposure)
    record.status_tag_details&.dig(:invoice, :status_text)
  end

  def self.payment_status_text(user, record, record_exposure)
    record.status_tag_details&.dig(:payment, :status_text)
  end

  def self.format_status(user, record, record_exposure)
    case record.status&.name&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :paid, :approved, :closed, :auto_approved, :sent_to_vendor, :po_revised, :vendor_confirmed
      format = 'success'
    when :processing
      if record.controlling_user_id == user.id
        format = 'warning'
      else
        format = 'info'
      end
    when :open, :retracted, :voided
      format = 'info'
    else
      format = 'danger'
    end
    format
  end
end