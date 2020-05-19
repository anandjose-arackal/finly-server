class Docs::P2P::PurchaseOrders::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions :purchase_order_initiator, :purchase_order_reviewer, :purchase_order_auditor, :admin
  resolver 'purchase_orders.default'
  reference '{{record.id}}', procurement_id: '{{record.procurement_id}}', procurement_type: 'po'
  custom_fields :purchase_order

  # Fixed column is always default true
  column :vendor, label: 'Vendor Details', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: "{{record.vendor.business_name}}", format: 'primary'
    text value: "Vendor ID: {{record.vendor.vendor_id}}"
  end

  column :po_number, sort: :po_number, label: "PO Number", default: true do
    text value: :po_number, format: "primary"
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

  column :po_status, label: "PO Status", default: true, includes: [:status] do
    indicator value: :po_status, format: :format_status
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

  IndexBuilder::API::ColumnTemplate::ControllingUser(self)
  IndexBuilder::API::ColumnTemplate::ControllingLevel(self)
  IndexBuilder::API::ColumnTemplate::ReviewProgress(self)

  column :advance_status, default: true, includes: [:status] do
    indicator value: :advance_amount_status, format: :format_advance_status
  end

  column :grn_status, default: true, includes: [procurement: [:status_tags, :invoices]] do
    indicator value: :grn_status_text, format: :grn_status_format
  end

  column :invoice_status, default: true, includes: [procurement: [:status_tags, :invoices]] do
    indicator value: :invoice_status_text, format: :invoice_status_format
  end

  column :payment_status, default: true, includes: [procurement: [:status_tags, :invoices]] do
    indicator value: :payment_status_text, format: :payment_status_format
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_ids
    counts = collection.group(:purchase_order_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    # Open / Retracted
    counter.add 90, 'Open', counts[PurchaseOrderStatus.id_for(:open)].to_i + counts[PurchaseOrderStatus.id_for(:retracted)].to_i

    # Awaiting Approval
    if user.has_permission?(awaiting_approval_roles)
      counter.add 91, 'Awaiting Approval',
                  PurchaseOrder.awaiting_action_items(user.id).count
    end

    counter.add PurchaseOrderStatus.id_for(:processing), "Processing", counts[PurchaseOrderStatus.id_for(:processing)].to_i

    # Approved / Auto Approved
    counter.add 92, 'Approved', counts[PurchaseOrderStatus.id_for(:approved)].to_i + counts[PurchaseOrderStatus.id_for(:auto_approved)].to_i

    [:rejected, :voided, :sent_to_vendor, :vendor_confirmed, :closed].each do |status|
      counter.add PurchaseOrderStatus.id_for(status), status.to_s.titleize, counts[PurchaseOrderStatus.id_for(status)].to_i
    end

    counter
  end

  def self.awaiting_approval_roles
    [:purchase_order_reviewer, :admin]
  end

  def self.po_status(context)
    return 'Awaiting Approval' if context[:record].purchase_order_status_id == PurchaseOrderStatus.id_for(:processing) and context[:record].controlling_user?(context[:user])

    context[:record].status&.name&.titleize
  end

  def self.cost_center_name(context)
    return "Multiple" if context[:exposure].cost_allocation_items

    context[:exposure].cost_center&.name
  end

  def self.department_name(context)
    return "Multiple" if context[:exposure].cost_allocation_items

    context[:exposure].department&.name
  end

  def self.grn_status_text(context)
    context[:record].status_tag_details&.dig(:grn, :status_text)
  end

  def self.grn_status_format(context)
    case context[:record].status_tag_details&.dig(:grn, :status)
    when 'init'
      return 'info'
    when 'processing'
      return 'warning'
    when 'completed'
      return 'success'
    else
      return 'info'
    end
  end

  def self.invoice_status_text(context)
    context[:record].status_tag_details&.dig(:invoice, :status_text)
  end

  def self.invoice_status_format(context)
    case context[:record].status_tag_details&.dig(:invoice, :status)
    when 'init'
      if context[:record].status_tag_details&.dig(:invoice, :status_text) == 'Invoice Processing'
        return 'warning'
      end
      return 'info'
    when 'processing'
      return 'warning'
    when 'completed'
      return 'success'
    else
      return 'info'
    end
  end

  def self.payment_status_text(context)
    context[:record].status_tag_details&.dig(:payment, :status_text)
  end

  def self.payment_status_format(context)
    case context[:record].status_tag_details&.dig(:payment, :status)
    when 'init'
      return 'info'
    when 'processing'
      return 'warning'
    when 'completed'
      return 'success'
    else
      return 'info'
    end
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected, :failed
      format = 'danger'
    when :paid, :approved, :closed, :auto_approved, :sent_to_vendor, :po_revised, :vendor_confirmed
      format = 'success'
    when :processing, :initiated
      if context[:record].controlling_user?(context[:user])
        format = 'warning'
      else
        format = 'info'
      end
    when :open, :retracted, :voided, :to_be_processed, :pending, :po_processing, :saved
      format = 'info'
    else
      format = 'danger'
    end
    format
  end

  def self.advance_amount_status(context)
    context[:record].advance_amount_status&.name || 'Pending'
  end

  def self.format_advance_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :failed
      format = 'danger'
    when :paid, :closed
      format = 'success'
    when :initiated
      if context[:record].controlling_user?(context[:user])
        format = 'warning'
      else
        format = 'info'
      end
    when :to_be_processed, :pending, :po_processing
      format = 'info'
    else
      format = 'info'
    end
    format
  end

end