class Docs::P2P::Invoices::Index < IndexBuilder::API

  resolver Docs::P2P::Invoices::Resolver

  attribute :vendor, label: 'Vendor Details',
            fixed: true,
            sort: :vendor_business_name,
            includes: [:vendor],
            template: IndexBuilder::Templates::PrimaryMultiline.(
                {
                    primary: "{{record.vendor.business_name}}",
                    sub_text_1: "Vendor ID: {{record.vendor.vendor_id}}"
                }
            )
  attribute :created_at, template: IndexBuilder::Templates::SimpleText.({primary: :created_at}), default: true
  attribute :invoice_number, template: IndexBuilder::Templates::SimpleText.({primary: :invoice_id}), default: true

end