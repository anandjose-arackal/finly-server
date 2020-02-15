class Docs::P2P::Invoices::Index < IndexBuilder::API

  resolver Docs::P2P::Invoices::Resolver

  attribute :vendor, label: 'Vendor Details',
            sort: :vendor_business_name,
            includes: [:vendor],
            template: IndexBuilder::Templates::PrimaryMultiline.({primary: "{{record.vendor.business_name}}", sub_text_1: "{{record.vendor.vendor_id}}"})
  attribute :created_at, template: IndexBuilder::Templates::SimpleText.({primary: :created_at}), default: true
  # attribute :updated_at, template: IndexBuilder::Templates::SimpleText.({primary: :updated_at})
  # attribute :created_by, template: IndexBuilder::Templates::SimpleText.({primary: "{{record.user.name}}"})
  # attribute :updated_by, template: IndexBuilder::Templates::SimpleText.(primary: "{{record.user.name}}")

end