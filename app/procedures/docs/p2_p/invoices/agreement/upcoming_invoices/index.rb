class Docs::P2P::Invoices::Agreement::UpcomingInvoices::Index < IndexBuilder::API

  resolver 'upcoming_invoices.default'
  reference '{{record.id}}', procurement_id: '{{record.procurement_id}}', procurement_type: "{{record.invoice_type.key}}"
  # custom_fields :invoice

  # Fixed column is always default true
  column :vendor, label: 'Vendor Details', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: "{{record.vendor.business_name}}", format: 'primary'
    text value: "Vendor ID: {{record.vendor.vendor_id}}"
  end

  # column :invoice_id, default: true, sort: true do
  #   text value: :template_invoice_id, format: 'primary'
  # end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :invoice_type, label: "Type", default: true, includes: [:invoice_type] do
    text value: -> (context) { context[:record].class.titleize }
  end

  # Todo figure out how to provide the status
  # column :status, default: true, includes: [:status] do
  #   indicator value: :invoice_status, format: :format_status
  # end

  column :invoice_date, sort: :date, default: true do
    date value: :date
  end

  column :due_date, sort: true, default: true do
    date value: :due_date
  end

  column :upcoming_in_days, sort: :due_date, default: true do
    text value: :upcoming_in_days
  end

  column :due_in_days, sort: :due_date, default: true do
    text value: :due_in_days
  end

  column :agreement_number, default: true, includes: [:payment_agreement] do
    text value: "{{record.payment_agreement.agreement_number}}"
  end

  column :start_date, sort: true, default: true do
    date value: :start_date
  end

  column :end_date, sort: true, default: true do
    date value: :end_date
  end

  column :gross_amount, sort: :gross_amount_value, includes: [gross_amount: :currency] do
    amount value: :gross_amount
  end

  column :discount_amount, sort: :discount_amount_value, includes: [discount_amount: :discount_amount] do
    amount value: :discount_amount
  end

  column :cgst_amount, sort: :tax_amount_value, label: 'CGST', includes: [tax_amount: :currency] do
    amount value: :cgst_amount
  end

  column :sgst_amount, sort: :tax_amount_value, label: 'SGST', includes: [tax_amount: :currency] do
    amount value: :sgst_amount
  end

  column :igst, sort: :tax_amount_value, label: 'IGST', includes: [tax_amount: :currency] do
    amount value: :igst_amount
  end

  column :tds_slab, sort: :tds_slab_name, includes: [:tds_slab] do
    text value: "{{record.tds_slab.name}}"
  end

  column :tds_rate, sort: :tds_slab_rate, includes: [:tds_rate] do
    text value: "{{record.tds_slab.rate}}"
  end

  column :tds_amount, sort: :tds_amount_value, includes: [tds_amount: :currency] do
    amount value: :tds_amount
  end

  column :freight_amount, sort: :freight_amount_value, includes: [freight_amount: :currency] do
    amount value: :freight_amount
  end

  column :net_amount, sort: :net_amount_value, includes: [net_amount: :currency] do
    amount value: :net_amount
  end

  column :advance_amount, sort: :advance_amount_value, includes: [advance_amount: :currency] do
    amount value: :advance_paid
  end

  column :balance_payable, includes: [balance_due: :currency] do
    amount value: :balance_payable
  end

  column :cost_center, default: true, includes: [:cost_center] do
    text value: :cost_center_name
  end

  column :department, default: true, includes: [:department] do
    text value: :department_name
  end

  column :vendor_location, default: false, includes: [:vendor_location] do
    text value: "{{record.vendor_location.location}}"
  end

  column :billing_location, default: false, includes: [:location] do
    text value: "{{record.billing_location.name}}"
  end

  column :shipping_location, default: false, includes: [:delivery_location] do
    text value: "{{record.shipping_location.name}}"
  end

  column :policy, sort: :payment_agreement_policy_name, default: true, includes: [payment_agreement: :policy] do
    text value: "{{record.payment_agreement.policy.name}}"
  end

  column :action, default: true do
    action :template,
           :create,
           action_condition: :can_create?,
           permissions: :agreement_invoice_initiator,
           label: 'Create Invoice',
           function: 'agreement_invoice_create'
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    # counts = collection.group(:invoice_status_id).count
    counter.add "rental", "Rental", 0
    counter.add "general", "General", 0
    # counter.add nil, "All", counts.values.reduce(0, :+)
    #
    # # Open - open/retracted
    # counter.add 90, 'Open', (
    #     counts[InwardInvoiceStatus.id_for(:open)].to_i +
    #     counts[InwardInvoiceStatus.id_for(:retracted)].to_i
    # )
    #
    # # Awaiting Approval
    # if user.has_permission?(awaiting_approval_roles)
    #   counter.add 91, 'Awaiting Approval',
    #               Invoice.awaiting_action_items(user).count
    # end
    #
    # # Processing
    # counter.add InwardInvoiceStatus.id_for(:processing), "Processing", counts[InwardInvoiceStatus.id_for(:processing)].to_i
    #
    # # Pending Payment - approved/auto_approved/partially_paid/unpaid/initiated
    # counter.add 92, 'Pending Payment', (
    # counts[InwardInvoiceStatus.id_for(:approved)].to_i +
    #     counts[InwardInvoiceStatus.id_for(:auto_approved)].to_i +
    #     counts[InwardInvoiceStatus.id_for(:partially_paid)].to_i +
    #     counts[InwardInvoiceStatus.id_for(:unpaid)].to_i +
    #     counts[InwardInvoiceStatus.id_for(:initiated)].to_i
    # )
    #
    # [:rejected, :paid, :closed, :voided, :pending].each do |status|
    #   counter.add InwardInvoiceStatus.id_for(status), status.to_s.titleize, counts[InwardInvoiceStatus.id_for(status)].to_i
    # end

    counter
  end

  def self.awaiting_approval_roles
    [:agreement_invoice_reviewer, :po_invoice_reviewer, :non_po_invoice_reviewer, :admin]
  end

  def self.invoice_status(context)
    return 'Awaiting Approval' if context[:record].invoice_status_id == InwardInvoiceStatus.id_for(:processing) and context[:record].controlling_user?(context[:user])

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

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :paid, :approved, :closed, :auto_approved, :unpaid, :partially_paid
      format = 'success'
    when :processing
      if context[:record].controlling_user?(context[:user])
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

  def self.can_create?(context)
    false
  end

end