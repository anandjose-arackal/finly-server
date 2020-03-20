class Docs::P2P::Invoices::Po::Index < IndexBuilder::API

  resolver Docs::P2P::Invoices::Resolver, params: {q: {"invoice_type_id_eq": InwardInvoiceType.id_for(:tax_invoice)}}

  reference '{{record.id}}', procurement_id: '{{record.procurement_id}}'

  # Fixed column is always default true
  column :vendor, label: 'Vendor Details', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: "{{record.vendor.business_name}}", format: 'primary'
    text value: "Vendor ID: {{record.vendor.vendor_id}}"
  end

  column :created_by, default: true, includes: [:created_by] do
    text value: "{{record.created_by.name}}"
    text value: "{{record.created_by.email}}"
  end

  column :created_at, sort: :created_at, default: true do
    date value: :created_at
  end

  column :invoice_id, sort: :invoice_id, label: "Invoice ID", default: true do
    badge value: :invoice_id, format: "success"
  end

  column :invoice_number, default: true do
    text value: :invoice_number
  end

  column :invoice_date, sort: :invoice_date, default: true do
    date value: :date
  end

  column :due_date, sort: :due_date, default: true do
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

  column :tds_amount, default: true, includes: [tds_amount: :currency] do
    amount value: "{{record.tds_amount.value}}",
           currency_code: "{{record.tds_amount.currency.country_code}}",
           currency_symbol: "{{record.tds_amount.currency.symbol}}"
  end

  column :tds_slab, default: true, includes: [:tds_slab] do
    text value: "{{record.tds_slab.name}}"
  end

  column :po_number, sort: :po_number, default: true, includes: [{procurement: :purchase_order}] do
    text value: :po_number
  end

  column :cost_center, sort: :cost_center_name, default: true, includes: [:cost_center] do
    text value: "{{record.cost_center.name}}"
  end

  column :department, sort: :department_name, default: true, includes: [:department] do
    text value: "{{record.department.name}}"
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

  column :approved_at, sort: :approved_at, default: true do
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

end