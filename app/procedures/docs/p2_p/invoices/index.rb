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

end