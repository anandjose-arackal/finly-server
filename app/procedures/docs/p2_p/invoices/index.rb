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
  column :created_by, default: true, includes: [:created_by], template: IndexBuilder::Templates::PrimaryMultiline.(
      {
          primary: "{{record.created_by.name}}",
          sub_text_1: "{{record.created_by.email}}"
      }
  )
  column :invoice_number, default: true, template: IndexBuilder::Templates::SimpleText.({primary: :invoice_id})
  column :invoice_date, default: true, template: IndexBuilder::Templates::SimpleText.({primary: :date})
  column :due_date, default: true, template: IndexBuilder::Templates::SimpleText.({primary: :due_date})
  column :net_amount, default: true, includes: [:net_amount], template: IndexBuilder::Templates::SimpleText.({primary: :net_amount})
  column :gross_amount, default: true, includes: [:gross_amount], template: IndexBuilder::Templates::SimpleText.({primary: :gross_amount})
  column :tds_amount, default: true, includes: [:tds_amount], template: IndexBuilder::Templates::SimpleText.({primary: :tds_amount})
  column :tds_slab, default: true, includes: [:tds_slab], template: IndexBuilder::Templates::SimpleText.({primary: "{{record.tds_slab.name}}"})
  column :po_number, default: true, includes: [{procurement: :purchase_order}], template: IndexBuilder::Templates::SimpleText.({primary: :po_number})
  column :cost_center, default: true, includes: [:cost_center], template: IndexBuilder::Templates::SimpleText.({primary: "{{record.cost_center.name}}"})
  column :department, default: true, includes: [:department], template: IndexBuilder::Templates::SimpleText.({primary: "{{record.department.name}}"})
  column :vendor_location, default: false, includes: [:gstin_location], template: IndexBuilder::Templates::SimpleText.({primary: "{{record.vendor_location.location}}"})
  column :billing_location, default: false, includes: [:billing_location], template: IndexBuilder::Templates::SimpleText.({primary: "{{record.billing_location.name}}"})
  column :shipping_location, default: false, includes: [:shipping_location], template: IndexBuilder::Templates::SimpleText.({primary: "{{record.shipping_location.name}}"})
  column :approved_at, default: true, template: IndexBuilder::Templates::SimpleText.({primary: :approved_at})

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