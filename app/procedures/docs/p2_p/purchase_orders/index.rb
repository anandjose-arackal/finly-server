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
    badge value: "{{record.status.name | upcase}}", format: :format_status
  end

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :net_amount, default: true, includes: [net_amount: :currency] do
    amount value: "{{record.net_amount.value}}",
           currency_code: "{{record.net_amount.currency.country_code}}",
           currency_symbol: "{{record.net_amount.currency.symbol}}"
  end

  column :gross_amount, default: true, includes: [gross_amount: :currency] do
    amount value: "{{record.gross_amount.value}}",
           currency_code: "{{record.gross_amount.currency.country_code}}",
           currency_symbol: "{{record.gross_amount.currency.symbol}}"
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

  column :payment_status, default: true, includes: [procurement: [:status_tags]]do
    text value: :payment_status_text
  end

  def self.awaiting_approval_roles
    :po_invoice_reviewer
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:invoice_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    if user.has_permission?(awaiting_approval_roles)
      counter.add 99, 'Awaiting Approval',
                  collection.where(invoice_status_id: InwardInvoiceStatus.id_for(:processing), controlling_user_id: user.id).count
    end
    InwardInvoiceStatus.all.each do |status|
      counter.add status.id, status.name.humanize, counts[status.id]
    end
    counter
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
    when :paid, :approved, :closed, :auto_approved
      format = 'success'
    when :processing
      if record.controlling_user_id == user
        format = 'warning'
      else
        format = 'info'
      end
    when :open, :retracted, :pending, :voided, :initiated
      format = 'info'
    when :unpaid, :partially_paid
      format = 'warning'
    else
      format = 'danger'
    end
    format
  end
end