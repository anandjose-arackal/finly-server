class Docs::P2P::Invoices::Index < IndexBuilder::API
  include DynamicAttributes

  resolver 'invoices.default'
  reference '{{record.id}}', procurement_id: '{{record.procurement_id}}', procurement_type: "{{record.invoice_type.key}}"

  # Fixed column is always default true
  column :vendor, label: 'Vendor Details', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: "{{record.vendor.business_name}}", format: 'primary'
    text value: "Vendor ID: {{record.vendor.vendor_id}}"
  end

  column :invoice_id, default: true, sort: true do
    text value: :invoice_id, format: 'primary'
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :invoice_type, label: "Type", default: true, includes: [:invoice_type] do
    text value: "{{record.invoice_type.name | upcase}}"
  end

  column :status, default: true, includes: [:status] do
    badge value: :invoice_status, format: :format_status
  end

  column :invoice_number, default: true do
    text value: :invoice_number, format: 'primary'
  end

  column :created_at, default: true do
    date value: :created_at
  end

  column :invoice_date, default: true do
    date value: :date
  end

  column :due_date, default: true do
    date value: :due_date
  end

  column :due_in_days, sort: :due_date, default: true do
    text value: :due_in_days
  end

  # Todo
  # column :agreement_number do
  #
  # end

  column :po_number, sort: :po_number, default: true, includes: [{procurement: :purchase_order}] do
    text value: :po_number
  end

  column :net_amount, default: true, includes: [net_amount: :currency] do
    amount value: :net_amount
  end

  column :gross_amount, default: true, includes: [gross_amount: :currency] do
    amount value: :gross_amount
  end

  column :balance_due, default: true, includes: [gross_amount: :currency] do
    amount value: :balance_due
  end

  column :tds_amount, default: true, includes: [tds_amount: :currency] do
    amount value: :tds_amount
  end

  column :tds_slab, default: true, includes: [:tds_slab] do
    text value: "{{record.tds_slab.name}}"
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

  column :billing_location, default: false, includes: [:location] do
    text value: "{{record.billing_location.name}}"
  end

  column :shipping_location, default: false, includes: [:delivery_location] do
    text value: "{{record.shipping_location.name}}"
  end

  column :controlling_user, default: true, includes: [:controlling_user] do
    user value: :controlling_user
  end

  column :controlling_level, default: true, includes: [:controlling_level] do
    text value: "{{record.controlling_level.name}}"
  end

  column :approved_at, default: true do
    date value: :approved_at
  end

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:invoice_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)

    # Open - open/retracted
    counter.add 90, 'Open', (
    (counts[InwardInvoiceStatus.id_for(:open)] || 0) +
        (counts[InwardInvoiceStatus.id_for(:retracted)] || 0)
    )

    # Awaiting Approval
    if user.has_permission?(awaiting_approval_roles)
      counter.add 91, 'Awaiting Approval',
                  collection.where(invoice_status_id: InwardInvoiceStatus.id_for(:processing), controlling_user_id: user.id).count
    end

    # Processing
    counter.add InwardInvoiceStatus.id_for(:processing), "Processing", counts[InwardInvoiceStatus.id_for(:processing)]

    # Pending Payment - approved/auto_approved/partially_paid/unpaid/initiated
    counter.add 92, 'Pending Payment', (
    (counts[InwardInvoiceStatus.id_for(:approved)] || 0) +
        (counts[InwardInvoiceStatus.id_for(:auto_approved)] || 0) +
        (counts[InwardInvoiceStatus.id_for(:partially_paid)] || 0) +
        (counts[InwardInvoiceStatus.id_for(:unpaid)] || 0) +
        (counts[InwardInvoiceStatus.id_for(:initiated)] || 0)
    )

    [:rejected, :paid, :closed, :voided, :pending].each do |status|
      counter.add InwardInvoiceStatus.id_for(status), status.to_s.titleize, counts[InwardInvoiceStatus.id_for(status)]
    end

    counter
  end

  def self.awaiting_approval_roles
    [:agreement_invoice_reviewer, :po_invoice_reviewer, :non_po_invoice_reviewer, :admin]
  end

  def self.invoice_status(context)
    return 'Awaiting Approval'.upcase if context[:record].invoice_status_id == InwardInvoiceStatus.id_for(:processing) and context[:record].controlling_user_id == context[:user].id

    context[:record].status&.name&.humanize&.upcase
  end

  def self.cost_center_name(context)
    return "Multiple" if context[:exposure].cost_allocation_items

    context[:exposure].cost_center&.name
  end

  def self.department_name(context)
    return "Multiple" if context[:exposure].cost_allocation_items

    context[:exposure].department&.name
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :paid, :approved, :closed, :auto_approved, :unpaid, :partially_paid
      format = 'success'
    when :processing
      if context[:record].controlling_user_id == context[:user].id
        format = 'warning'
      else
        format = 'info'
      end
    when :open, :retracted, :pending, :voided, :initiated
      format = 'info'
      # when :unpaid, :partially_paid
      #   format = 'warning'
    else
      format = 'danger'
    end
    format
  end

end