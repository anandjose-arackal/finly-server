class Docs::P2P::Invoices::Index < IndexBuilder::API

  resolver Docs::P2P::Invoices::Resolver

  column :vendor, label: 'Vendor Details',
         fixed: true,
         sort: :vendor_business_name,
         includes: [:vendor],
         template: IndexBuilder::Templates::PrimaryMultiline.(
             {
                 primary: "{{record.vendor.business_name}}",
                 sub_text_1: "Vendor ID: {{record.vendor.vendor_id}}"
             }
         )
  column :created_at, default: true, template: IndexBuilder::Templates::SimpleText.({primary: :created_at})
  column :invoice_number, default: true, template: IndexBuilder::Templates::SimpleText.({primary: :invoice_id})

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