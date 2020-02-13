class Filters::TestApi < Filters::API

  attribute :invoice_id, label: "Invoice ID", type: :text
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :created_by_name, label: "Created By", type: :lookup, scope: 'users'
  attribute :vendor_business_name, label: "Vendor Name"
  attribute :vendor_vendor_id, label: "Vendor ID"

end