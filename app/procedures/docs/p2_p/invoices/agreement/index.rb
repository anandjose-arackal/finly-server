class Docs::P2P::Invoices::Agreement::Index < IndexBuilder::API

  resolver Docs::P2P::Invoices::Resolver

  def self.resolve(context)
    super(context)
    type_id = InwardInvoiceType.ids_for(:general_invoice, :rental_invoice, :recurring_invoice, :agreement_invoice)
    context['model.records'] = context['model.records'].where(invoice_type_id: type_id)
  end


  reference '{{record.id}}', procurement_id: '{{record.procurement_id}}', procurement_type: "non_po", invoice_type: "recurring_invoice"

  # Fixed column is always default true
  column :vendor, label: 'Vendor Details', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: "{{record.vendor.business_name}}", format: 'primary'
    text value: "Vendor ID: {{record.vendor.vendor_id}}"
  end

  column :created_by, default: true, includes: [:created_by] do
    text value: "{{record.created_by.name}}"
    text value: "{{record.created_by.email}}"
  end

  column :created_at, default: true do
    date value: :created_at
  end

  column :invoice_id, default: true do
    badge value: :invoice_id, format: "success"
  end

  column :invoice_type, default: true do
    badge value: "{{record.invoice_type.name}}", format: "success"
  end

  column :invoice_number, default: true do
    text value: :invoice_number
  end

  column :invoice_date, default: true do
    date value: :date
  end

  column :due_date, default: true do
    date value: :due_date
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

  column :balance_due, default: true, includes: [gross_amount: :currency] do
    amount value: "{{record.balance_due.value}}",
           currency_code: "{{record.balance_due.currency.country_code}}",
           currency_symbol: "{{record.balance_due.currency.symbol}}"
  end

  column :tds_amount, default: true, includes: [tds_amount: :currency] do
    amount value: "{{record.tds_amount.value}}",
           currency_code: "{{record.tds_amount.currency.country_code}}",
           currency_symbol: "{{record.tds_amount.currency.symbol}}"
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

  column :approved_at, default: true do
    date value: :approved_at
  end

  counter -> (collection) do
    counter = IndexBuilder::Counter.new :invoice_status_id
    counts = collection.group(:invoice_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
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

end